# Docker 環境建置與部屬工具

## 簡介

適用於搭載`Ubuntu24.04`的`WSL2`環境。

## 目錄結構

```plaintext
docker-deploy/
├── .env                    # 環境變數檔案
├── .env.example            # 環境變數範例檔案
├── docker-compose.yml      # Docker Compose 主配置檔
├── .gitignore              # Git 忽略檔案
├── scripts/                # 腳本目錄
│   ├── setup.sh            # 環境安裝腳本
│   ├── deploy.sh           # 專案部署腳本
│   └── alias.sh            # 別名定義腳本
├── nginx/                  # Nginx 設定
│   ├── Dockerfile          # Nginx 的 Dockerfile
│   ├── default.conf        # Nginx 的預設配置檔案
│   ├── example.conf        # Nginx 的站點範例配置檔案
│   ├── conf.d/             # Nginx 站點配置檔案
│   └── logs/               # Nginx 日誌目錄
├── php/                    # PHP 設定
│   ├── 7.3/                # PHP 7.3 相關檔案
│   │   ├── Dockerfile      # PHP 7.3 的 Dockerfile
│   │   └── php.ini         # PHP 7.3 的設定檔
│   ├── 7.4/                # PHP 7.4 相關檔案
│   │   ├── Dockerfile      # PHP 7.4 的 Dockerfile
│   │   └── php.ini         # PHP 7.4 的設定檔
│   ├── 8.0/                # PHP 8.0 相關檔案
│   │   ├── Dockerfile      # PHP 8.0 的 Dockerfile
│   │   └── php.ini         # PHP 8.0 的設定檔
│   ├── 8.1/                # PHP 8.1 相關檔案
│   │   ├── Dockerfile      # PHP 8.1 的 Dockerfile
│   │   └── php.ini         # PHP 8.1 的設定檔
│   └── 8.3/                # PHP 8.3 相關檔案
│       ├── Dockerfile      # PHP 8.3 的 Dockerfile
│       └── php.ini         # PHP 8.3 的設定檔
├── mysql/                  # MySQL 設定
│   └── my.cnf              # MySQL 配置檔案
├── redis/                  # Redis 設定
│   ├── Dockerfile          # Redis 的 Dockerfile (如需自定義)
│   └── redis.conf          # Redis 配置檔案
└── projects/               # 專案目錄
    └── .gitkeep            # 保持目錄存在的空檔案
```

## 必要條件

- WSL 1.1.3.0 版或更新版本。
- Windows 11 64 位：家用版或專業版 21H2 或更高版本，或企業版或教育版 21H2 或更高版本。
- Windows 10 64 位（建議）：家用版或專業版 22H2（組建 19045）或更高版本，或企業版或教育版 22H2（組建 19045） 或更高版本。 （最低）：家用版或專業版 21H2（組建 19044）或更高版本，或企業版或教育版 21H2（組建 19044） 或更高版本。 更新 Windows
- 具有第二層地址轉譯的 64 位處理器（SLAT）。
- 4GB 系統 RAM。
- 在 BIOS 中啟用硬體虛擬化。
- 安裝 WSL，並為在 WSL 2 中執行的 Linux 發行版本設定使用者名稱和密碼。
- 安裝 Visual Studio Code （選擇性）。 這可提供最佳體驗，包括能夠在遠端 Docker 容器內撰寫程式碼和偵錯，並連接到您的 Linux 散發套件。
- 安裝 Windows 終端機 （選擇性） 。

> WSL 可以在 WSL 第 1 版或 WSL 2 模式中執行散發套件。 您可藉由開啟 PowerShell 並輸入下列內容進行檢查：wsl -l -v。 輸入下列項目，確定您的散發套件已設定為使用 WSL 2：wsl --set-version \<distro\> 2。 將 \<distro\> 取代為散發版本名稱(例如 Ubuntu 18.04)。

> 在 WSL 第 1 版中，由於 Windows 和 Linux 之間的基本差異，Docker 引擎無法直接在 WSL 內執行，因此 Docker 小組已使用 Hyper-V VM 和 LinuxKit 開發替代解決方案。 不過，由於 WSL 2 現在在具有完整系統呼叫容量的 Linux 核心上執行，Docker 可以在 WSL 2 中完全執行。 這表示 Linux 容器可以在不模擬的情況下以原生方式執行，進而提升 Windows 和 Linux 工具之間的效能和互通性。

## 安裝 Docker Desktop

1. 下載 [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) 並遵循安裝指示。
2. 安裝之後，從 Windows [開始] 功能表啟動 Docker Desktop，然後從工作列的隱藏圖示功能表中選取 Docker 圖示。 以滑鼠右鍵按一下圖示以顯示 Docker 命令功能表，然後選取 [設定]。![alt text](https://learn.microsoft.com/zh-tw/windows/wsl/media/docker-starting.png)
3. 確定已核取 [設定]>[一般] 中的 [使用 WSL 2 型引擎]。![alt text](https://learn.microsoft.com/zh-tw/windows/wsl/media/docker-running.png)
4. 移至 [設定]>[資源]>[WSL 整合]，從您要啟用 Docker 整合的已安裝 WSL 2 散發套件中選取。![alt text](https://learn.microsoft.com/zh-tw/windows/wsl/media/docker-dashboard.png)
5. 若要確認 Docker 已安裝，請開啟 WSL 散發套件 (例如 Ubuntu)，並輸入下列命令來顯示版本和組建編號：`docker --version`
6. 執行簡單的內建 Docker 映像，測試您的安裝是否運作正常，使用：`docker run hello-world`

下列是一些實用的 Docker 命令，可知道：

- 輸入以下命令可列出 Docker CLI 中可用的命令：`docker`
- 使用以下命令，列出特定命令的資訊：`docker <COMMAND> --help`
- 使用以下命令，列出電腦上的 Docker 映像 (此時就是 hello-world 映像)：`docker image ls --all`
- 列出您電腦上的容器，其中包含：`docker container ls --all` 或 `docker ps -a` (若沒有 `-a` 顯示所有旗標，只會顯示執行中的容器)
- 列出有關 Docker 安裝的全系統資訊，包括 WSL 2 內容中可供您使用的統計數據和資源（CPU 和記憶體），包括： `docker info`
