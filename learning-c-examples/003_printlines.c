/* Эта программа покажет, как написать много строк в консоль. */

#include <stdio.h>

int main (int argc, char **argv)
{
	// Объявляем переменнyю для счетчика.
	int i;

	// Используем цикл "for",
	// выведем 15 строк.
	for (i = 1; i <= 15; i = i + 1) {

		// Выводим строку в консоль
		printf("Line #%i\n", i);
	}

	// Выходим из программы. Возвращаем системе
	// код успешного завершения.
	return 0;
}