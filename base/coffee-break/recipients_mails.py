#!/usr/bin/env python3
"""Emit participant emails for the sendmail Tekton task (space-separated tokens).

The sendmail task splits recipients on spaces. Override by rebuilding the image or
mounting upstream recipients_mails.py from ccit/coffee-break.
"""

import os


def main() -> None:
    # Default keeps pipeline wiring obvious; override with RECIPIENT_EMAILS="a@x.com b@y.com"
    default = "sfathii@redhat.com"
    line = os.environ.get("RECIPIENT_EMAILS", default).strip()
    print(line)


if __name__ == "__main__":
    main()
