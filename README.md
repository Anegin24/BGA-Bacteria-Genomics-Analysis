# Ubuntu XFCE + VNC/noVNC + Micromamba Bioinformatics Docker

This project provides a Docker image based on **Ubuntu 22.04**, running the **XFCE desktop environment**, accessible via **VNC** or **noVNC** (in your browser). It also includes a **bioinformatics environment** which process bacterial genomics data created using **Micromamba** and a custom `env.yaml`.

---

## ✅ Features

- Lightweight Ubuntu GUI via XFCE
- Access via VNC (port `5901`) or browser (noVNC via port `6080`)
- Pre-installed bioinformatics tools via Conda (Bioconda)
- XFCE terminal included (no GUI terminal errors)

---

## 📁 Project Structure

```
bga-docker/
├── Dockerfile
└── env.yaml
```

---

## ⚙️ Requirements

- Docker installed
- Basic terminal/Dockerfile experience

---

## 🔧 Setup Instructions

### 1. Create `env.yaml`

```yaml
name: bga
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - samtools
  - bwa
  - sickle
  - fastqc
  - python=3
  - minimap2
  - ragtag
  - abricate
  - mlst
  - spades
  - mummer
  - mash
  - roary
  - mafft
  - prokka
  - quast
  - perl-padwalker
  - perl-db-file
  - porechop
  - sra-tools
  - sickle-trim
  - trimmomatic
  - bakta
  - pip
  - pip:
      - numpy
      - matplotlib
      - matplotlib-venn
      - biopython
      - dREP
```

### 2. Build the Docker Image

```bash
docker build -t bga-env .
```

---

## 🚀 Run the Container

```bash
docker run -it -p 5901:5901 -p 6080:6080 \
  --name bga \
  -v /home/<user>/Bioinformatics/Training:/home/docker/data \
  bga-env
```

---

## 🌐 Access the Desktop

- Open browser and go to: `http://<HOST_IP>:6080`
- Click the **fullscreen** button on the top right (if desired)
- VNC password: `docker` (default)

---

## 🛠 Tech Stack

- Ubuntu 22.04
- XFCE Desktop
- TigerVNC + noVNC
- Micromamba + Bioconda

---

## 🧪 Troubleshooting

- **Missing terminal error:** Resolved by installing `xfce4-terminal`
- **Permission denied on .vnc:** Avoid mounting over `/home/docker`; use `/data` instead

---

## ✅ Success!

You now have a powerful, GUI-enabled Ubuntu container for bioinformatics research 🚀
