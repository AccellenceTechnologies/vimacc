# vimacc Docker Image

This repository contains the Docker-based runtime setup for **vimacc**, a video management system developed by Accellence Technologies GmbH.

The provided setup builds a Debian-based image, installs vimacc packages, and optionally provides a GUI via VNC.

> **Note:** This setup is focused on container runtime. The vimacc software itself is not open source.

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/AccellenceTechnologies/vimacc.git
cd vimacc/tools/docker

# Copy your vimacc .deb package into the build folder
mkdir -p build/vimacc/deb
cp /path/to/vimacc.deb build/vimacc/deb/

# Build the container image
docker compose build

# Run the container
docker compose up -d
```

> 🗂 Make sure the `.deb` package is present at `tools/docker/build/vimacc/deb/`, otherwise the image will not contain the vimacc software.


```bash
# Clone the repository
git clone https://github.com/AccellenceTechnologies/vimacc.git
cd vimacc/tools/docker

# Build the container image
docker compose build

# Run the container
docker compose up -d
```

The container starts with the default configuration and exposes all required vimacc ports.

---

## 🧰 Features

- Based on Debian 11
- GUI support via VNC (port 5901)
- Built-in confd templating system
- Environment-variable-driven service configuration
- Predefined port mappings with clear structure

---

## 🧱 Build Arguments

| Argument | Description |
|----------|-------------|
| `PRODUCT` | (reserved) Always use `vimacc` |
| `GUI`     | Set to `true` to include the GUI (VNC on port 5901) |

Example:
```yaml
args:
  - PRODUCT=vimacc
  - GUI=true
```

---

## ⚙️ Environment Variables

| Variable | Purpose |
|---------|---------|
| `VIMACC_HOSTNAME` | Container hostname & internal controller name |
| `VIMACC_CONFIG_CLIENT_SERVERTYPE` | One of `config`, `proxy`, or `slave` |
| `VIMACC_CONFIG_CLIENT_SERVER1_HOST` | Primary config server address |
| `VIMACC_CONFIG_CLIENT_SERVER1_PORT` | Primary config server port |
| `VIMACC_CONFIG_CLIENT_SERVER2_HOST` | Secondary config server address (optional) |
| `VIMACC_CONFIG_CLIENT_SERVER2_PORT` | Secondary config server port |
| `VIMACC_CONFIG_SERVER_PORT` | Local config instance port |
| `VIMACC_CONFIG_SLAVE_SERVER_PORT` | Local config-slave port |
| `VIMACC_CONFIG_PROXY_SERVER_PORT` | Local config-proxy port |
| `VIMACC_REPORTCLIENT_SERVERPORT` | Reporting client port |
| `VIMACC_INTERFACE_OPERATORPORT` | Operator interface port |
| `VIMACC_INTERFACE_DATACONNECTIONPORT` | Data channel port |
| `VIMACC_PLAYBACK_OPERATORPORT` | Playback operator port |
| `VIMACC_PLAYBACK_DATACONNECTIONPORT` | Playback data channel |
| `VIMACC_PLAYBACK_PROXY_OPERATORPORT` | Proxy playback operator |
| `VIMACC_PLAYBACK_PROXY_DATACONNECTIONPORT` | Proxy playback data channel |
| `VIMACC_INTERFACE_PROXY_OPERATORPORT` | Proxy operator interface |
| `VIMACC_INTERFACE_PROXY_DATACONNECTIONPORT` | Proxy data connection |
| `VIMACC_STREAMING_OPTIONS_PAYLOADMTUSIZE` | Stream MTU (e.g. for VPN) |
| `VIMACC_STREAMING_OPTIONS_DEJITTERDELAY` | Jitter buffer delay |
| `VIMACC_GUI_VIDEORENDERER` | Renderer backend (e.g. `software`) |
| `VIMACC_GUI_AUTOLOGOUT_INACTIVITYSECS` | Auto logout (idle time) |
| `VIMACC_GUI_SHOWALLLIVESTREAMS` | Show all live streams in GUI |

---

## 🔌 Port Mapping

```yaml
ports:
  - "5901:5901"   # GUI (VNC)
  - "4225:4225"   # VIMACC_REPORTCLIENT_SERVERPORT
  - "9360:9360"   # VIMACC_CONFIG_PROXY_SERVER_PORT
  - "9365:9365"   # VIMACC_CONFIG_SLAVE_SERVER_PORT
  - "9370:9370"   # VIMACC_CONFIG_SERVER_PORT (shared with SERVER1/2)
  - "9371:9371"   # VIMACC_PLAYBACK_OPERATORPORT
  - "9372:9372"   # VIMACC_PLAYBACK_DATACONNECTIONPORT
  - "9375:9375"   # VIMACC_INTERFACE_OPERATORPORT
  - "9376:9376"   # VIMACC_INTERFACE_DATACONNECTIONPORT
  - "9729:9729"   # Internal data port (e.g. database sync)
  - "9731:9731"   # VIMACC_PLAYBACK_PROXY_OPERATORPORT
  - "9732:9732"   # VIMACC_PLAYBACK_PROXY_DATACONNECTIONPORT
  - "9735:9735"   # VIMACC_INTERFACE_PROXY_OPERATORPORT
  - "9736:9736"   # VIMACC_INTERFACE_PROXY_DATACONNECTIONPORT
```

---

## 🖥️ Accessing the Container

To open a shell in the running container:

```bash
docker exec -it -u vimacc vimacc-vms bash
```

If the container was built with `GUI=true`, you can also access the graphical user interface via VNC:

- **VNC port:** `5901`
- **Default resolution:** 1024×768 (can be customized via build)
- Use a VNC client (e.g. TigerVNC, RealVNC) to connect to `localhost:5901`

> 🧪 Authentication is not enabled by default. For production use, secure the VNC session.


```bash
docker exec -it -u vimacc vimacc-vms bash
```

Main start scripts:

- `/usr/local/bin/start.sh` – Initializes confd and vimacc
- `/usr/local/bin/start_vimacc.sh` – Starts vimacc processes
- `/usr/local/bin/start_vnc.sh` – Starts GUI (if enabled)
- `/usr/local/bin/stop_vimacc.sh` – Stops vimacc processes

---

## 📦 Built With

- Debian 11
- `confd` v0.16.0
- `openssl` 3.0.8
- `xfce4` (GUI environment, optional)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-topic`).
3. Commit your changes.
4. Push to your fork.
5. Create a pull request.

Please refer to [CONTRIBUTING.md](../../CONTRIBUTING.md) for full contribution guidelines.

---

## 📝 License

This project is licensed under the MIT License – see [LICENSE](../../LICENSE) for details.

---

## 👨‍💻 Authors

- **Alexander Merker** – *Initial work* – [Accellence Technologies GmbH](mailto:merker@accellence.de)
- **Benjamin Lilienthal** – *Release & publishing* – [Accellence Technologies GmbH](mailto:lilienthal@accellence.de)

---

## 🌐 More

Visit us at [https://vimacc.de](https://vimacc.de)
