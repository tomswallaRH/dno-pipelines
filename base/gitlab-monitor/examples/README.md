# GitLab Monitor Report Example

This directory contains an example output showing what the GitLab monitor generates when monitoring your Jenkins-related repositories.

## Example File

### `daily_report.md`
- **Markdown format** suitable for documentation systems
- Perfect for including in wikis, README files, or documentation sites
- All links are preserved and clickable
- Clean, readable format for technical audiences
- Can be converted to other formats easily
- Shows git-based analysis including commits, branches, tags, and file changes

## Data Coverage

Each report includes activity from the past 24 hours for:

### Jenkins CSB Controller
- `ccit/deployments/jenkins-csb/controller`
- Most active repository with merge requests, commits, issues, and pipelines

### DNO Configuration
- `ccit/deployments/dno-config`
- Configuration changes and deployments

### ArgoCD Deployments
- `ccit/deployments/argocd`
- Application deployment definitions

### DNS Integration
- `ccit/integration/dns`
- DNS configuration and integration

## Activity Types

For each repository, the monitor tracks:

- **Merge Requests**: Title, author, status (opened/merged/closed), creation date
- **Commits**: Message, author, timestamp, with clickable links
- **Issues**: Title, status, author, creation date
- **Pipelines**: Status (success/failed/running), branch, timestamp

## Email Notifications

When the pipeline completes successfully, team members receive email notifications confirming that:
- The report has been generated
- Data is available for the specified time period
- Link to access the report (if shared storage is configured)

## Usage

This example shows what your team will receive when the GitLab monitor runs daily, providing complete visibility into development activity across all your Jenkins-related repositories. 