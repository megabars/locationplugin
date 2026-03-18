# LocationPlugin

Лёгкое приложение для панели меню macOS, которое отображает флаг страны вашего текущего внешнего IP-адреса.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)

## Что делает

LocationPlugin живёт в верхней панели macOS и показывает эмодзи флага страны, которой соответствует ваш внешний IP-адрес. Нажмите на флаг, чтобы увидеть детали.

| Состояние | Иконка в панели |
|---|---|
| Запуск | 🌐 |
| Определено | флаг страны, например 🇷🇺 🇩🇪 🇯🇵 |
| Ошибка | ⚠️ |

## Возможности

- **Флаг страны в панели меню** — обновляется автоматически в фоне
- **Дропдаун с деталями** — внешний IP-адрес, город, страна
- **Ошибка видна прямо в панели** — при сбое сети в панели появляется ⚠️, в меню — кнопка Retry
- **Настраиваемый интервал обновления** — 30 сек / 1 мин / 5 мин / 10 мин / 30 мин (по умолчанию: 1 минута), сохраняется между перезапусками
- **Нет иконки в Dock** — работает тихо в фоне
- **Нет сторонних зависимостей** — чистый Swift + SwiftUI

## Требования

- macOS 13 Ventura или новее
- Xcode 15 или новее (для сборки из исходников)

## Сборка и запуск

```bash
git clone https://github.com/megabars/locationplugin.git
cd locationplugin
xcodebuild -project LocationPlugin.xcodeproj -scheme LocationPlugin -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/LocationPlugin-*/Build/Products/Debug/LocationPlugin.app
```

Или откройте `LocationPlugin.xcodeproj` в Xcode и нажмите **⌘R**.

## Как это работает

1. Получает внешний IP через [ipify.org](https://api.ipify.org)
2. Определяет геолокацию через [ip-api.com](http://ip-api.com)
3. Переводит двухбуквенный код страны ISO 3166-1 в эмодзи флага через Unicode Regional Indicator Symbols
4. Повторяет по настроенному интервалу

Приложение использует App Sandbox только с правом `network.client`.

## Конфиденциальность

Никакие данные не сохраняются и не передаются, кроме двух API-запросов для определения геолокации:
- `https://api.ipify.org` — возвращает ваш публичный IP
- `http://ip-api.com` — возвращает страну и город для этого IP

## Лицензия

MIT
