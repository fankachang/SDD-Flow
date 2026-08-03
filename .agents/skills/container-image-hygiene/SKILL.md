---
name: container-image-hygiene
description: Auto-clean dangling (<none>) images after Podman/Docker builds to reclaim disk. Use when building with podman/docker compose build, keeping the system clean, or troubleshooting <none> images left after image prune.
license: Complete terms in LICENSE.txt
---

# Container Image Hygiene (Auto-cleanup After Build)

**Level**: Basic  
**Estimated Time**: 2-10 minutes  
**Last Updated**: 2026-01-26

## Objectives

- Automatically clean up dangling images (commonly `<none>`) after building images
- Reduce risk of disk being filled with old images
- Provide both safe (conservative) and advanced (aggressive) cleanup modes

## Quick Start (Recommended)

Execute the following build scripts from the project root:

-- Windows: `.agents/skills/container-image-hygiene/scripts/build.ps1`
-- Linux/Mac: `.agents/skills/container-image-hygiene/scripts/build.sh`

### Windows (Podman)

```ps1
# Build + auto-cleanup dangling images
.\.github\skills\container-image-hygiene\scripts\build.ps1

# Force rebuild (no cache) + auto-cleanup
.\.github\skills\container-image-hygiene\scripts\build.ps1 -Force

# Build only, no cleanup
.\.github\skills\container-image-hygiene\scripts\build.ps1 -NoPrune

# If you want to also clean stopped containers (helps remove old images still referenced)
.\.github\skills\container-image-hygiene\scripts\build.ps1 -PruneContainers
```

### Linux/Mac (Docker or Podman)

```bash
# Build + auto-cleanup dangling images
./.agents/skills/container-image-hygiene/scripts/build.sh

# Force rebuild (no cache) + auto-cleanup
./.agents/skills/container-image-hygiene/scripts/build.sh --force

# Build only, no cleanup
./.agents/skills/container-image-hygiene/scripts/build.sh --no-prune

# If you want to also clean stopped containers (helps remove old images still referenced)
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

- **Don't do aggressive cleanup while important containers are running**: Conservative `podman image prune -f` is usually fine, but `-a` / `system prune` may affect resources you didn't expect.
- **Root cause of大量 `<none>`**: Usually caused by repeatedly rebuilding with the same tag (e.g., `latest`), making old versions untagged; therefore "auto-cleanup after build" is the most hassle-free approach.

## Checklist

- [ ] Use `.agents/skills/container-image-hygiene/scripts/build.ps1` / `.agents/skills/container-image-hygiene/scripts/build.sh` in build process
- [ ] Run `podman image prune -f` after build
- [ ] If large `<none>` still persists, check and remove stopped containers before pruning
