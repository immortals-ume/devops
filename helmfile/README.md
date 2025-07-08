# Helmfile-based Multi-Service Deployment

This directory contains a sample, production-grade Helmfile setup for managing multiple services (e.g., backend, UI) in a modular, scalable way.

## Structure
- `helmfile-init.yaml`: Initial setup (e.g., namespace creation)
- `helmfile-backend.yaml`: All service releases (backend, UI, etc.)
- `helmfile.yaml`: Root file referencing the above
- `backend.json`, `ui.json`: Example deployment spec files for automation/documentation

## Usage
1. **Install Helmfile:**
   ```sh
   brew install helmfile
   ```
2. **Apply all deployments:**
   ```sh
   helmfile -f helmfile.yaml apply
   ```
   This will:
   - Run `helmfile-init.yaml` (create namespaces, etc.)
   - Deploy all services in `helmfile-backend.yaml` using their respective values/secrets.

3. **Add/Remove services:**
   - Edit `helmfile-backend.yaml` and add new values/secrets files as needed.

## Best Practices
- Use a separate values and secrets file for each service.
- Use deployment spec files (`.json`) for automation and documentation.
- Keep your Helmfile structure modular for easy scaling and maintenance.
- Use environments and selectors for advanced use cases (see Helmfile docs).

## References
- [Helmfile Docs](https://github.com/roboll/helmfile) 