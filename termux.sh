if ! command -v termux-setup-storage; then
  echo This script can be executed only on Termux
  exit 1
fi

termux-wake-lock

pkg update -y && pkg upgrade -y
pkg install python3 git libjpeg-turbo zlib libwebp libffi -y || exit 2

python3 -m pip install -U pip
LDFLAGS="-L${PREFIX}/lib/" CFLAGS="-I${PREFIX}/include/" pip3 install --upgrade wheel pillow

if [[ -d "reider-userbot" ]]; then
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
  api_id="14895435"
  api_hash="e8205235cc85f4d3b9b8733a24954950"
else
  read -r -p "API_HASH > " api_hash
fi

cat >.env <<EOL
API_ID=${api_id}
API_HASH=${api_hash}
EOL

pip3 install flask

python3 install.py 3

if [[ ! -f "lordnet.session" ]]; then
  echo "Видимо не удалось установить юзербот..."
  exit 1
fi

echo
echo "                                      "
echo "  _   _ ___  ___ _ __| |__   ___ | |_ "
echo "| | | / __|/ _ | '__| '_ \ / _ \| __| "
echo "| |_| \__ |  __| |  | |_) | (_) | |_  "
echo " \__,_|___/\___|_|  |_.__/ \___/ \__|  "
echo "                                      "
echo "============================"
echo "Отлично! reider-userbot установлен успешно!"
echo "Напишите: \"python3 run.py\""
echo "============================"
