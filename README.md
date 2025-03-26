# haskell-wb-wc

Проект студента Блинов Илья Игоревич: веб версия утилиты wc.

## Описание проекта

Пользователь может отправлять MultipartForm запросы с текстовым файлом и получать для него статистику по типу обычной для утилиты wc.

## Состояние проекта

[x] Первая версия, Proof of Concept. Просто работа с MultipartForm запросами, реализация wc из домашнего задания, тестирование через отправку этого README.
[x] Подготовлен тестовый файл: sample.txt в 1,12 ГБ. Статистики первого wc для него: 25018508 194885810 1209339403 (строки, слова, символы)
[x] Реализован подсчет слов, проверена корректность
[x] Реализована параллельная обработка (интерфейс обращения к WordCount пришлось немного поменять для удобства)
[x] Реализована функция для обработки строки по батчам и переводам их в stream
[x] Написаны тесты
[x] Добавлены файлы размером 500MB, 2GB, 3GB для тестов производительности
[x] Добавлен flamegraph

## Анализ производительности

На файле размером в 1GB:
1. Proof of Concept: Elapsed (wall clock) time (h:mm:ss or m:ss): 0:27.25, Maximum resident set size (kbytes): 1816
2. Подсчет слов: Elapsed (wall clock) time (h:mm:ss or m:ss): 0:39.20, Maximum resident set size (kbytes): 1816
3. С параллельной обработкой и 16 Haskell потоками: Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.07, Maximum resident set size (kbytes): 1820

Итоговая реализация на файлах размером 500MB, 1GB, 2GB, 3GB:
1. (500MB): Elapsed (wall clock) time (h:mm:ss or m:ss): 0:07.92, Maximum resident set size (kbytes): 1820
2. (1GB): Elapsed (wall clock) time (h:mm:ss or m:ss): 0:16.96, Maximum resident set size (kbytes): 1820
3. (2GB): Elapsed (wall clock) time (h:mm:ss or m:ss): 0:29.03, Maximum resident set size (kbytes): 1824
4. (3GB): Elapsed (wall clock) time (h:mm:ss or m:ss): 0:40.95, Maximum resident set size (kbytes): 1824

Время растет линейно.