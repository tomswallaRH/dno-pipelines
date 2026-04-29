#!/usr/bin/env python3
"""
GitLab Monitor - Daily Activity Report Generator
Analyzes cloned Git repositories and generates reports.
"""

import os
import sys
import argparse
import logging
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any, Optional



# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class GitRepositoryAnalyzer:
    def __init__(self, base_url: str = "https://gitlab.cee.redhat.com"):
        self.base_url = base_url.rstrip('/')
    
    def _run_git_command(self, repo_path: Path, command: List[str]) -> str:
        """Run a git command in the repository directory."""
        try:
            result = subprocess.run(
                ["git"] + command,
                cwd=repo_path,
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            logger.error(f"Git command failed in {repo_path}: {e}")
            return ""
    
    def get_commits(self, repo_path: Path, since: datetime) -> List[Dict[str, Any]]:
        """Get commits from the repository since a specific date."""
        since_str = since.strftime("%Y-%m-%d")
        
        # Get commit log with specific format
        log_format = "--pretty=format:%H|%an|%ae|%ad|%s"
        command = ["log", f"--since={since_str}", log_format, "--date=iso"]
        
        output = self._run_git_command(repo_path, command)
        commits = []
        
        if output:
            for line in output.split('\n'):
                if '|' in line:
                    parts = line.split('|', 4)
                    if len(parts) == 5:
                        commit_hash, author_name, author_email, date, message = parts
                        commits.append({
                            "id": commit_hash,
                            "short_id": commit_hash[:8],
                            "message": message.strip(),
                            "author_name": author_name.strip(),
                            "author_email": author_email.strip(),
                            "created_at": date.strip(),
                            "web_url": f"{self.base_url}/-/commit/{commit_hash}"
                        })
        
        return commits
    
    def get_branches(self, repo_path: Path) -> List[Dict[str, Any]]:
        """Get branches from the repository."""
        command = ["branch", "-r", "--format=%(refname:short)|%(committerdate:iso)|%(authorname)"]
        output = self._run_git_command(repo_path, command)
        branches = []
        
        if output:
            for line in output.split('\n'):
                if '|' in line and 'origin/' in line:
                    parts = line.split('|', 2)
                    if len(parts) >= 2:
                        branch_name = parts[0].strip().replace('origin/', '')
                        date = parts[1].strip() if len(parts) > 1 else ""
                        author = parts[2].strip() if len(parts) > 2 else ""
                        
                        if branch_name and branch_name != 'HEAD':
                            branches.append({
                                "name": branch_name,
                                "last_commit_date": date,
                                "last_author": author,
                                "web_url": f"{self.base_url}/-/tree/{branch_name}"
                            })
        
        return branches
    
    def get_tags(self, repo_path: Path) -> List[Dict[str, Any]]:
        """Get tags from the repository."""
        command = ["tag", "-l", "--sort=-version:refname"]
        output = self._run_git_command(repo_path, command)
        tags = []
        
        if output:
            for tag in output.split('\n')[:10]:  # Last 10 tags
                if tag.strip():
                    # Get tag info
                    tag_info_cmd = ["show", "--format=%an|%ad", "--no-patch", tag.strip()]
                    tag_info = self._run_git_command(repo_path, tag_info_cmd)
                    
                    author = ""
                    date = ""
                    if '|' in tag_info:
                        parts = tag_info.split('|', 1)
                        author = parts[0].strip()
                        date = parts[1].strip() if len(parts) > 1 else ""
                    
                    tags.append({
                        "name": tag.strip(),
                        "author": author,
                        "created_at": date,
                        "web_url": f"{self.base_url}/-/tags/{tag.strip()}"
                    })
        
        return tags
    
    def get_file_changes(self, repo_path: Path, since: datetime) -> List[Dict[str, Any]]:
        """Get file changes since a specific date."""
        since_str = since.strftime("%Y-%m-%d")
        command = ["log", f"--since={since_str}", "--name-only", "--pretty=format:%H|%an|%ad|%s", "--date=iso"]
        
        output = self._run_git_command(repo_path, command)
        changes = []
        current_commit = None
        
        if output:
            for line in output.split('\n'):
                line = line.strip()
                if '|' in line and len(line.split('|')) >= 4:
                    # This is a commit line
                    parts = line.split('|', 3)
                    current_commit = {
                        "commit_hash": parts[0],
                        "author": parts[1],
                        "date": parts[2],
                        "message": parts[3],
                        "files": []
                    }
                elif line and current_commit and not '|' in line:
                    # This is a file name
                    current_commit["files"].append(line)
                elif not line and current_commit:
                    # End of commit, add to changes
                    if current_commit["files"]:
                        changes.append(current_commit)
                    current_commit = None
        
        return changes
    
    def get_repository_activity(self, repo_name: str, repo_path: Path, since: datetime) -> Optional[Dict[str, Any]]:
        """Analyze a cloned repository and extract activity information."""
        logger.info(f"Analyzing repository: {repo_name}")
        
        if not repo_path.exists() or not (repo_path / '.git').exists():
            logger.warning(f"Repository not found or not a git repository: {repo_path}")
            return None
        
        # Map repository directory names to project paths
        project_path_map = {
            "jenkins-csb-controller": "ccit/deployments/jenkins-csb/controller",
            "dno-config": "ccit/deployments/dno-config", 
            "argocd": "ccit/deployments/argocd",
            "dns": "ccit/integration/dns"
        }
        
        project_path = project_path_map.get(repo_name, repo_name)
        
        activity = {
            "project_path": project_path,
            "project_url": f"{self.base_url}/{project_path}",
            "repository_name": repo_name,
            "commits": self.get_commits(repo_path, since),
            "branches": self.get_branches(repo_path),
            "tags": self.get_tags(repo_path),
            "file_changes": self.get_file_changes(repo_path, since),
            # Placeholder for GitLab-specific features (would need API)
            "merge_requests": [],
            "issues": [],
            "pipelines": []
        }
        
        return activity








def generate_markdown_report(data: Dict[str, Any], output_path: str):
    """Generate Markdown report."""
    lines = []
    lines.append("# Git Repository Daily Activity Report")
    lines.append("")
    lines.append(f"**Generated:** {data['report_date']}")
    lines.append(f"**Period:** {data['period_start']} to {data['period_end']}")
    lines.append("")
    
    for project in data['projects']:
        lines.append(f"## [{project['project_path']}]({project['project_url']})")
        lines.append("")
        
        # Commits
        lines.append(f"### Recent Commits ({len(project['commits'])})")
        lines.append("")
        if project['commits']:
            for commit in project['commits']:
                message = commit['message'][:80] + "..." if len(commit['message']) > 80 else commit['message']
                commit_date = commit['created_at'][:10] if commit['created_at'] else "Unknown"
                lines.append(f"- [`{commit['short_id']}`]({commit['web_url']}) {message} by {commit['author_name']} ({commit_date})")
        else:
            lines.append("*No commits in this period*")
        lines.append("")
        
        # Branches
        lines.append(f"### Active Branches ({len(project['branches'])})")
        lines.append("")
        if project['branches']:
            for branch in project['branches'][:10]:  # Show only first 10 branches
                branch_date = branch['last_commit_date'][:10] if branch['last_commit_date'] else "Unknown"
                lines.append(f"- [{branch['name']}]({branch['web_url']}) - last updated {branch_date} by {branch['last_author']}")
        else:
            lines.append("*No branches found*")
        lines.append("")
        
        # Tags
        lines.append(f"### Recent Tags ({len(project['tags'])})")
        lines.append("")
        if project['tags']:
            for tag in project['tags'][:5]:  # Show only first 5 tags
                tag_date = tag['created_at'][:10] if tag['created_at'] else "Unknown"
                lines.append(f"- [{tag['name']}]({tag['web_url']}) by {tag['author']} ({tag_date})")
        else:
            lines.append("*No tags found*")
        lines.append("")
        
        # File Changes Summary
        if project.get('file_changes'):
            lines.append(f"### File Changes Summary ({len(project['file_changes'])} commits)")
            lines.append("")
            
            # Count file types
            file_types = {}
            total_files = 0
            for change in project['file_changes']:
                for file_path in change['files']:
                    total_files += 1
                    ext = file_path.split('.')[-1].lower() if '.' in file_path else 'no-ext'
                    file_types[ext] = file_types.get(ext, 0) + 1
            
            lines.append(f"**Total files changed:** {total_files}")
            lines.append("")
            
            if file_types:
                lines.append("**File types modified:**")
                for ext, count in sorted(file_types.items(), key=lambda x: x[1], reverse=True)[:10]:
                    lines.append(f"- `.{ext}`: {count} files")
                lines.append("")
        
        # Placeholder sections (would need GitLab API)
        lines.append("### Merge Requests")
        lines.append("*API integration required for merge request data*")
        lines.append("")
        
        lines.append("### Issues")  
        lines.append("*API integration required for issue data*")
        lines.append("")
        
        lines.append("### Pipelines")
        lines.append("*API integration required for pipeline data*")
        lines.append("")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(lines))





def main():
    parser = argparse.ArgumentParser(description='Git Repository Activity Monitor')
    parser.add_argument('--hours', type=int, default=24, help='Hours to look back (default: 24)')
    args = parser.parse_args()
    
    # Initialize repository analyzer
    analyzer = GitRepositoryAnalyzer()
    
    # Calculate time range
    end_time = datetime.now()
    start_time = end_time - timedelta(hours=args.hours)
    
    logger.info(f"Analyzing repository activity from {start_time} to {end_time}")
    
    # Look for cloned repositories in the repos directory
    repos_dir = Path('repos')
    if not repos_dir.exists():
        logger.error("No repos directory found. Repositories should be cloned to ./repos/")
        sys.exit(1)
    
    # Collect activity for all cloned repositories
    project_activities = []
    for repo_dir in repos_dir.iterdir():
        if repo_dir.is_dir():
            repo_name = repo_dir.name
            activity = analyzer.get_repository_activity(repo_name, repo_dir, start_time)
            if activity:
                project_activities.append(activity)
    
    if not project_activities:
        logger.warning("No repositories found or analyzed successfully")
        
    # Prepare report data
    report_data = {
        'report_date': end_time.strftime('%Y-%m-%d %H:%M:%S'),
        'period_start': start_time.strftime('%Y-%m-%d %H:%M:%S'),
        'period_end': end_time.strftime('%Y-%m-%d %H:%M:%S'),
        'projects': project_activities
    }
    
    # Create reports directory
    reports_dir = Path('reports')
    reports_dir.mkdir(exist_ok=True)
    
    # Generate report
    logger.info("Generating report...")
    generate_markdown_report(report_data, str(reports_dir / 'daily_report.md'))
    
    logger.info("Report generated successfully!")
    logger.info(f"  - Markdown: {reports_dir / 'daily_report.md'}")


if __name__ == '__main__':
    main() 