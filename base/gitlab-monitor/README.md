# GitLab Monitor

A Tekton-based Git repository monitoring system that clones repositories and analyzes local Git history to generate daily activity reports with email notifications.

## Files

- `monitor/main.py` - Main Python script that analyzes git repositories and generates reports
- `run-gitlab-monitor.task.yaml` - Tekton Task definition
- `gitlab-monitor-pipeline.pipeline.yaml` - Tekton Pipeline definition
- `gitlab-monitor-pipeline.eventlistener.yaml` - GitLab webhook event listener
- `gitlab-monitor-pipeline.triggerbinding.yaml` - GitLab webhook trigger binding
- `gitlab-monitor-pipeline.triggertemplate.yaml` - GitLab webhook trigger template
- `sendmail.task.yaml` - Email notification task

## Setup

1. Deploy the pipeline and webhook components:
   ```bash
   kubectl apply -k .
   ```

2. The pipeline automatically clones the following Jenkins-related repositories:
   - `ccit/deployments/jenkins-csb/controller`
   - `ccit/deployments/dno-config`
   - `ccit/deployments/argocd`
   - `ccit/integration/dns`

3. Configure GitLab webhooks to trigger the pipeline automatically, or run manually:
   ```bash
   tkn pipeline start gitlab-monitor-pipeline \
     --param gitrepositoryurl=https://gitlab.cee.redhat.com/ccit/deployments/jenkins-csb/controller.git \
     --param gitrevision=main \
     --param sender=gitlab-monitor@redhat.com \
     --param recipients="devops@redhat.com team@redhat.com" \
     --workspace name=output,claimName=your-pvc
   ```
   
   **Note:** No GitLab token required - the pipeline uses git-clone tasks and local git analysis only.

## Reports Generated

The monitor generates a daily report in the `reports/` directory:

- `daily_report.md` - Markdown report suitable for documentation and sharing

## Data Collected

For each cloned repository, the monitor analyzes:

- **Recent Commits**: Message, author, timestamp, commit hash
- **Active Branches**: Branch names, last update dates, last authors
- **Recent Tags**: Tag names, authors, creation dates
- **File Changes**: File modification statistics and types
- **Git History**: Complete local git repository analysis

All items include clickable links to the GitLab web interface.

**Note**: GitLab-specific features (merge requests, issues, pipelines) require API integration and are currently shown as placeholders.

## Email Notifications

The pipeline automatically sends email notifications when the report is generated successfully. The email includes:

- Confirmation that the GitLab monitor has completed
- Repository URL and revision information
- Notification that the Markdown report is available in the workspace

Email notifications are sent via the Red Hat SMTP server (`smtp.corp.redhat.com`) and can be configured with custom sender and recipient addresses.

## Usage

The script supports the following command-line options:

- `--hours N` - Number of hours to look back (default: 24)
- `--config path` - Path to config file (default: config.yaml)

Example:
```bash
python main.py --hours 48 --config my-config.yaml
```

## Parameters

- `gitrepositoryurl` - Git repository URL (defaults to jenkins-csb-controller repo)
- `gitrevision` - Git revision/branch (defaults to main)
- `sender` - Email sender address (defaults to gitlab-monitor@redhat.com)
- `recipients` - Space-delimited list of email recipients (defaults to devops@redhat.com)

## Environment Variables

None required - the monitor uses only local git commands and standard library functions. 