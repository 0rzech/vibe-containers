# Vibe Containers

This project provides a containerized environment for running [Mistral Vibe](https://mistral.ai/products/vibe) open source coding agent CLI.
It includes a `Containerfile` and helper scripts to build and run containers with proper user permissions and a bit better security settings.

## Features

- **A Bit More Secure Container**: Runs with dropped capabilities and no new privileges.
- **User Namespace Isolation**: Uses `--userns keep-id` for proper file permissions.
- **Persistent Configuration**: Mounts the vibe configuration directory.
- **Current Directory Access**: Mounts the current working directory.

## Files

- `Containerfile`: Dockerfile that builds a Fedora-based image with Mistral Vibe installed and a few CLI binaries.
- `build`: Script to build the container image with proper user/group arguments.
- `bin/vibe-container`: Script to run the Mistral Vibe container.
- `bin/vibe-acp-container`: Script to run the Mistral Vibe ACP ([Agent Client Protocol](https://agentclientprotocol.com)) container.

## Prerequisites

- Podman installed.
- Proper user permissions to run containers.

## Usage

### Build the Container

```bash
./build
```

This will create a container image tagged as `vibe-sandbox` with your current user's UID/GID.

### Run Mistral Vibe

```bash
./bin/vibe-container
```

This launches an interactive container with Mistral Vibe running in your current directory.

### Run Mistral Vibe ACP

```bash
./bin/vibe-acp-container
```

This launches an interactive container with Mistral Vibe ACP running in your current directory.

This script is for use with editors and IDEs with support ACP.

## How it Works

The working directory (`$PWD`) inside containers will be the same as on the host when containers are run.
The containers assume rootless [Podman](https://podman.io) with a non-root user inside.
This is why host UID and GID are the same inside containers.

## Limitations

* The agent can only run binaries that are already in the container, which in this case means no SDKs.
* Containers have network access.
* The scripts assume that the `save_dir` in `config.toml` is set to effective value of `${VIBE_HOME:-${HOME}/.vibe}`.

## Security Features

- All capabilities dropped (`--cap-drop all`).
- No new privileges (`--security-opt no-new-privileges`).
- User namespace isolation (`--userns keep-id`).
- Root password disabled and account expired.

## Environment Variables

- `VIBE_HOME`: Path to the vibe configuration directory (defaults to `~/.vibe`).

## License

    Vibe Containers
    Copyright (C) 2026  Piotr Orzechowski [orzechowski.tech]

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Disclaimer

This project is in no way associated with or endorsed by [Mistral AI](https://mistral.ai).
