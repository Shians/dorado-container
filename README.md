# dorado-container

Docker and Singularity container images for the Dorado basecaller.

## Version Management

Version information is centralized in two files:
- `VERSION`: Contains the Dorado version number (e.g., `1.1.1`)
- `CHECKSUM`: Contains the SHA256 checksum for the release tarball

Both container definitions ([Dockerfile](Dockerfile) and [dorado.def](dorado.def)) read from these files during build, ensuring consistency across Docker and Singularity images.

## Updating to a New Version

1. Update the version in `VERSION`
2. Update the SHA256 checksum in `CHECKSUM`
3. Commit and push - GitHub Actions will build both images automatically

## Nextflow Compatibility

The containers include `procps-ng` to provide the `ps` command required by Nextflow for task metrics collection.
