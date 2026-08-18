# Working rules

## Worktrees for project work and one-offs

For project work and new one-offs, identify early — before making changes — that the work should move into a dedicated git worktree under the working repo's `.worktrees/` subfolder (e.g. `.worktrees/<branch-name>`), and do the work there instead of on the main checkout. Ensure `.worktrees/` is listed in the repo's `.gitignore` (add it if missing) so worktrees never show up as untracked files.

After a PR is merged, clean up locally: remove the worktree and delete its local branch.

## Commit frequently, push to a draft PR

When a piece of work is done — a slice lands, tests pass, a file reaches a good state — commit it right away rather than batching everything into one commit at the end. Small, frequent commits as the work progresses.

Don't leave the work as local commits: push the branch and open a **draft PR** early (first meaningful commit), then keep pushing to it as commits land. Mark the PR ready for review only when asked.

## Communication style
Use ASD-STE-100 when you speak to the operator.
