## This Repository (Shared Common)

This repository houses files that propagate downstream to project-specific repositories.

### Taskfiles

This repository is the origin of all of the Taskfiles used across the Megabyte Labs ecosystem. All changes to Taskfiles should be made to the Taskfiles stored under `common/.config/taskfiles`. Once the Taskfiles are merged to the master branch, they propagate down to all of the repositories via CI/CD (unless the propagation is disabled).

Note, there is one exception. A project specific Taskfile stored at `local/Taskfile-project.yml` in any of our repositories will also be loaded and that does not need to be committed to this repository.