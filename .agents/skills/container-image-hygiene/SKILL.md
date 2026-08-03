---
name: container-image-hygiene
description: Opt-in cleanup of dangling (<none>) images after Podman/Docker builds to reclaim disk. Use when building with podman/docker compose build, keeping the system clean, or troubleshooting <none> images left after image prune.
license: Complete terms in LICENSE.txt
---

# Container Image Hygiene (Opt-in Cleanup)

**Level**: Basic  
**Estimated Time**: 2-10 minutes  
**Last Updated**: 2026-01-26

## Objectives

- Identify dangling images (commonly `<none>`) produced by image builds
- Reduce risk of disk being filled with old images
- Provide both safe (conservative) and advanced (aggressive) cleanup modes

## Quick Start (Recommended)

Execute the following build scripts from the project root. They build without deleting images by default. Before enabling cleanup, use the VS Code `vscode/askQuestions` tool to obtain explicit confirmation and keep `allowFreeformInput: true`.

-- Windows: `.agents/skills/container-image-hygiene/scripts/build.ps1`
-- Linux/Mac: `.agents/skills/container-image-hygiene/scripts/build.sh`

### Windows (Podman)

```ps1
# Build only; no cleanup by default
.\.agents\skills\container-image-hygiene\scripts\build.ps1

# Build + explicit dangling-image cleanup
.\.agents\skills\container-image-hygiene\scripts\build.ps1 -Prune

# Force rebuild only
.\.agents\skills\container-image-hygiene\scripts\build.ps1 -Force

# Force rebuild + explicit dangling-image cleanup
.\.agents\skills\container-image-hygiene\scripts\build.ps1 -Force -Prune

# Explicitly skip cleanup (same as the default)
.\.agents\skills\container-image-hygiene\scripts\build.ps1 -NoPrune

# Also clean stopped containers; requires explicit cleanup confirmation
.\.agents\skills\container-image-hygiene\scripts\build.ps1 -PruneContainers
```

### Linux/Mac (Docker or Podman)

```bash
# Build only; no cleanup by default
./.agents/skills/container-image-hygiene/scripts/build.sh

# Build + explicit dangling-image cleanup
./.agents/skills/container-image-hygiene/scripts/build.sh --prune

# Force rebuild only
./.agents/skills/container-image-hygiene/scripts/build.sh --force

# Force rebuild + explicit dangling-image cleanup
./.agents/skills/container-image-hygiene/scripts/build.sh --force --prune

# Explicitly skip cleanup (same as the default)
./.agents/skills/container-image-hygiene/scripts/build.sh --no-prune

# Also clean stopped containers; requires explicit cleanup confirmation
./.agents/skills/container-image-hygiene/scripts/build.sh --prune-containers
```

## Conservative Cleanup (dangling images only)

This mode is safest: only deletes dangling images that have no tag and are no longer referenced.

```ps1
podman image prune -f
```

Verify:

```ps1
# Should return empty or very few
podman images -f "dangling=true"
```

## Advanced Cleanup (handling large <none> still present after prune)

If you still see large `<none>` images (e.g., 8GB), common causes are:

- Containers (including stopped ones) still reference that image
- The image is not dangling (e.g., still referenced by build cache/containers), so `image prune` won't remove it

### Step 1: Find which containers are still using the image

```ps1
podman ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
```

You can also check if the image ID is still referenced by any container as an ancestor:

```ps1
podman ps -a --filter ancestor=<IMAGE_ID>
```

If you find stopped containers referencing old images, you can delete the stopped containers (note: this removes the container itself, but does NOT delete your project files or bind mount source folders).

```ps1
podman container prune -f
```

### Step 2: Run image prune again

```ps1
podman image prune -f
```

### What if it still won't delete? (Common: layer still shared by new image)

If `podman images -f "dangling=true"` still shows large `<none>` images, and `podman ps -a --filter ancestor=<IMAGE_ID>` returns containers, it means the image's layers are still shared by the current image/containers; `image prune` won't remove it.

Options (choose based on acceptable disruption):

- **Most conservative**: Leave it alone; clean it after your next `--no-cache` rebuild and container replacement.
- **Accept rebuild/downtime**: Stop and remove related containers → remove dependent newer images → then remove the `<none>` image, finally rebuild with `--no-cache`.

## Aggressive Mode (not recommended as default)

If you're sure you want to remove "all unused images" (may include base images that will need re-downloading), use:

```ps1
# Remove all unused images (broader than dangling)
podman image prune -a -f
```

Or full system cleanup (may affect more resources: stopped containers, unused networks, unused images):

```ps1
podman system prune -f
```

## Important Notes

- **Require explicit confirmation for every prune operation**: Even conservative `podman image prune -f` deletes resources; `-a` / `system prune` may affect resources you didn't expect.
- **Root cause of大量 `<none>`**: Usually caused by repeatedly rebuilding with the same tag (e.g., `latest`), making old versions untagged; inspect and clean them only after explicit confirmation.

## Checklist

- [ ] Use `.agents/skills/container-image-hygiene/scripts/build.ps1` / `.agents/skills/container-image-hygiene/scripts/build.sh` in build process
- [ ] Keep the default build path free of cleanup operations
- [ ] Use `-Prune` / `--prune` only after explicit confirmation
- [ ] If large `<none>` still persists, check and remove stopped containers before pruning
