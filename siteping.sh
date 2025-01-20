#!/bin/bash

SITE="$1"  # Наш сайт ($1 принимает первое значение)
DELAY="10"  # сек

if [ -z "$2" ]; then
  NAME=$SITE  # Имя сайта
else
  NAME=$2
fi


# Принимаем ключ -m если нужно
while getopts ":m:" opt; do
  case $opt in
    m) max_errors="$OPTARG";;
    \?) echo "Неправильный ключ"; exit 1;;
  esac
done
max_errors=${max_errors:-20}  # Маклимальное количество ошибок до отключения
error_count=0  # счетчик ошибок

echo "Проверка доступности $NAME/$SITE. Период $DELAY c"

while true
do
  # Проверка доступности сайта
  ping_output=$(ping -c 1 -w 1 "$SITE" 2>&1)
  TIME=$(date '+%d-%m-%y %H:%M:%S')
  if echo "$ping_output" | grep -q "bytes from"; then
    # Если сайт доступен, выводим сообщение
    latency=$(echo "$ping_output" |& grep -o "time=[^ ]*" | cut -d "=" -f 2)
    echo "$TIME [INFO] Сайт $NAME доступен. ($latency мс)"
    error_count=0
  else
    # Если сайт недоступен, выводим сообщение о неполадках
    echo "$TIME [WARNING] Ожадание сайта $NAME превышено!"
    notify-send -u "critical" -t 30000 -i error "Ожадание сайта $NAME превышено!"
    error_count=$((error_count+1))
    # Если ошибок больше необходимого завершаем цыкл
    if [ $error_count -ge $max_errors ]; then 
      break 
    fi
  fi

  # Пауза 
  sleep $DELAY
done

echo "$TIME [ERROR] Сайт $NAME не доступен."
notify-send -u "critical" -t 0 -i error "Сайт $NAME не доступен."
