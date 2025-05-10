# dynamic-ip-cloudflare-sync

動態 IP CloudFlare 同步

## 專案簡介

本專案用於自動偵測本機動態 IP 並同步更新至 Cloudflare DNS，適合家用或小型伺服器環境，確保網域名稱能正確指向最新的外部 IP。

## 特色

- 自動偵測外部 IP 變化
- 透過 Cloudflare API 自動更新 DNS 記錄
- 支援日誌記錄
- Shell 腳本簡單易用

## 安裝與設定

1. 複製本專案至本地端：
   ```sh
   git clone <本專案網址>
   cd dynamic-ip-cloudflare-sync
   ```

2. 複製設定檔範本並編輯：
   ```sh
   cp secret.sh.dist secret.sh
   cp ddns.sh.dist ddns.sh
   ```
   - 編輯 `secret.sh`，填入 Cloudflare API Token、Zone ID、DNS 記錄等資訊。

3. 設定排程 (crontab) 定時執行：
   ```sh
   crontab -e
   ```
   加入類似以下內容，每 5 分鐘執行一次：
   ```
   */5 * * * * /bin/zsh /path/to/dynamic-ip-cloudflare-sync/ddns.sh >> /path/to/dynamic-ip-cloudflare-sync/log/cron.log 2>&1
   ```

## 目錄結構

- ddns.sh.dist：主程式腳本範本
- secret.sh.dist：API 金鑰與設定範本
- log：日誌資料夾

## 注意事項

- 請勿將 `secret.sh` 上傳至公開儲存庫，避免洩漏敏感資訊。
- 需具備 Cloudflare API 權限。
