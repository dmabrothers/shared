/* Эта программа покажет, как сложить одно число с другим
 * и вывести результат в консоль.
 */

#include <stdio.h>

int main (int argc, char **argv)
{
	// Объявляем переменные, в которых будем хранить числа.
	int i;
	int k;
	int result;

	// Инициализируем переменные числами
	// (записываем числа в переменные)
	i = 2;
	k = 9;

	// Складываем i, k и сохраняем результат
	// в переменную result
	result = i + k;

	// Показываем сообщение с результатом 
	printf("Result is %i.\n", result);
	// Здесь происходит вызов функции printf(),
	// в первом аргументе передается строка
	// с сообщением, вместо %i подставится
	// второй аргумент, который мы тоже передаем,
	// это наш результат сложения.
	// \n означает перевод строки. Чтобы понять
	// зачем он, сотрите \n чтобы получилось
	// "Result is %i." скомпилируйте и
	// запустите программу.

	// Выходим из программы. Возвращаем системе
	// код успешного завершения.
	return 0;
}
