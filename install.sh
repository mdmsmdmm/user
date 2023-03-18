#!/bin/bash
if command -v termux-setup-storage; then
  echo "Termux Installer: https://raw.githubusercontent.com/NEGR431/reider-userbot/main/termux.sh"
  exit 1
fi

apt update -y
apt install python3 python3-pip git python3-dev libwebp-dev libz-dev libjpeg-dev libopenjp2-7 libtiff5 python3-opencv -y || exit 2

python3 -m pip install -U pip
python3 -m pip install -U setuptools wheel
python3 -m pip install -U pillow opencv-python

if [[ -d "reider-userbot" ]]; then
  # shellcheck disable=SC2164
  cd reider-userbot
elif [[ -f ".env.dist" ]] && [[ -f "run.py" ]] && [[ -d "modules" ]]; then
  :
else
  git clone https://github.com/NEGR431/reider-userbot || exit 2
  cd reider-userbot || exit 2
fi

if [[ -f ".env" ]] && [[ -f "lordnet.session" ]]; then
  echo "Видимо у вас уже установлен reider-userbot. Выход..."
  exit
fi

python3 -m pip install -U -r requirements.txt || exit 2

echo
echo "Введите API_ID и API_HASH"
echo "Вы можете взять их тут -> https://my.telegram.org/apps"
echo "Не вводите ничего, чтобы использовать по умолчанию"
read -r -p "API_ID > " api_id

if [[ $api_id = "" ]]; then
  api_id="10639791"
  api_hash="b2037d158a9ff12c285d4ec7e1f64040"
else
  read -r -p "API_HASH > " api_hash
fi

cat >.env <<EOL
API_ID=${api_id}
API_HASH=${api_hash}
EOL

chown -R $SUDO_USER:$SUDO_USER .

echo
echo "Выберите тип установки:"
echo "[1] PM2"
echo "[2] Systemd service"
echo "[3] Custom (default)"
read -r -p "> " install_type

python3 -m pip install flask

python3 install.py $install_type

if [[ ! -f "reider.session" ]]; then
  echo "Видимо не удалось установить юзербот..."
  exit
fi

case $install_type in
1)
  if ! command -v pm2; then
    curl -fsSL https://deb.nodesource.com/setup_17.x | bash
    apt install nodejs -y
    npm install pm2 -g
    pm2 startup
    env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $SUDO_USER --hp /home/$SUDO_USER
  fi
  pm2 start run.py --name reider --interpreter python3
  pm2 save

  echo
  echo "                                      "
  echo "  _   _ ___  ___ _ __| |__   ___ | |_ "
  echo "| | | / __|/ _ | '__| '_ \ / _ \| __| "
  echo "| |_| \__ |  __| |  | |_) | (_) | |_  "
  echo " \__,_|___/\___|_|  |_.__/ \___/ \__|  "
  echo "                                      "
  echo "Отлично! reider-userbot установлен успешно!"
  echo "Тип установки: PM2"
  echo "Запуск: \"pm2 start reider\""
  echo "Выключить: \"pm2 stop reider\""
  echo "Название процесса: reider"
  echo "============================"
  ;;
2)
  cat >/etc/systemd/system/reider.service <<EOL
[Unit]
Description=Service for reider userbot
[Service]
Type=simple
ExecStart=$(which python3) ${PWD}/run.py
WorkingDirectory=${PWD}
Restart=always
User=${SUDO_USER}
Group=${SUDO_USER}
[Install]
WantedBy=multi-user.target
EOL
  systemctl daemon-reload
  systemctl start reider
  systemctl enable reider

  echo
  echo "                                      "
  echo "  _   _ ___  ___ _ __| |__   ___ | |_ "
  echo "| | | / __|/ _ | '__| '_ \ / _ \| __| "
  echo "| |_| \__ |  __| |  | |_) | (_) | |_  "
  echo " \__,_|___/\___|_|  |_.__/ \___/ \__|  "
  echo "                                      "
  echo "Отлично! reider-userbot установлен успешно!"
  echo "Тип установки: Systemd service"
  echo "Запуск: \"sudo systemctl start reider\""
  echo "Выключить: \"sudo systemctl stop reider\""
  echo "============================"
  ;;
*)
  echo
  echo "                                      
  echo "  _   _ ___  ___ _ __| |__   ___ | |_ "
  echo "| | | / __|/ _ | '__| '_ \ / _ \| __| "
  echo "| |_| \__ |  __| |  | |_) | (_) | |_  "
  echo " \__,_|___/\___|_|  |_.__/ \___/ \__|  "
  echo "                                      "
  echo "Отлично! reider-userbot установлен успешно!"
  echo "Тип установки: Custom"
  echo "Запуск: \"python3 run.py\""
  echo "============================"
  ;;
esac

chown -R $SUDO_USER:$SUDO_USER . || exit 1
