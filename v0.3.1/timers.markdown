## Таймеры

### setTimeout(callback, delay, [arg], [...])

Позволяет выполнить переданный `callback` через `delay` миллисекунд.
Возвращает ID таймаута — `timeoutId` для последующего использования с `clearTimeout()`.

### clearTimeout(timeoutId)

Отменяет установленный таймаут.

### setInterval(callback, delay, [arg], [...])

Позволяет выполнять переданный `callback` каждые `delay` миллисекунд.
Возвращает ID интервала — `intervalId` для использования с `clearInterval()`.
Кроме того, можно передавать аргументы callback'у.

### clearInterval(intervalId)

Прекращает действие интервального таймера.

