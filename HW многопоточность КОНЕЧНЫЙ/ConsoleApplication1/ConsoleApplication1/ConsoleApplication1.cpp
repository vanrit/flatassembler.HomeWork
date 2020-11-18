#include <iostream>
#include <thread>
#include <chrono>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mutex>
#include <deque>
#include <vector>

//Симонович Иван Сергеевич БПИ 193 Вариант 19
using namespace std;


//Класс клиент-валентинки
class Valentine
{
public:
	Valentine()
	{
		text = "";
	}

	Valentine(const string& text, int& num)
	{
		this->text = text;
		this->num = num;
	}

	/// <summary>
	/// Получаем Текст
	/// </summary>
	/// <returns></returns>
	string getText()
	{
		return text;
	}
	
	/// <summary>
	/// Получаем номер
	/// </summary>
	/// <returns></returns>
	int getNum()
	{
		return num;
	}
private:
	int num = 0;
	string text;
};

//Класс, где содержится логика сервера-студентки
class Server
{
public:

	Server()
	{
		winner = -1;
	}
	
	/// <summary>
	/// Отправка сообщений клиентами на сервер
	/// </summary>
	/// <param name="letter"></param>
	void enqueueRequest(Valentine* letter)
	{
		mu.lock();
		letters.push_back(letter);
		mu.unlock();
	}

	/// <summary>
	/// Проверка определен ли победитель
	/// </summary>
	/// <returns></returns>
	bool isResponseReady()
	{
		return winner != -1;
	}

	/// <summary>
	/// Сервер отправляет ответ клиенту
	/// Является ли его письмо выигрышным
	/// </summary>
	/// <param name="letter">письмо</param>
	/// <returns></returns>
	bool getResponse(Valentine* letter)
	{
		//Блокировка потока
		mu.lock();
		int letterIndex = -2;
		for (int i = 0; i < letters.size(); i++)
		{
			//Находим индекс введеного письма
			if (letters[i] == letter)
			{
				letterIndex = i;
				break;
			}
		}
		//Сравниваем с выигрышным индексом
		bool response = (letterIndex == winner);
		mu.unlock();
		return response;
	}

	/// <summary>
	/// Основная логика работы сервера, запускается в потоке
	/// </summary>
	void serverMain()
	{
		srand(time(NULL));
		printf("[SERVER] Начался новый день. Жду, пока утро закончится.\n");
		//Задержка перед отправкой
		this_thread::sleep_for(chrono::milliseconds(3000));

		//Блокируем поток мютексом
		mu.lock();
		printf("[SERVER] Утро закончилось. Получено %d писем.\n", (int)letters.size());
		winner = rand() % letters.size(); //Определяем индекс победителя
		//Указатель на письмо победителей
		Valentine* winnerLetter = letters[winner];

		//Вывод инфы о победителе
		printf("[SERVER] Победило письмо номер %d из комнаты %d с текстом \"%s\".\n", winner+1, winnerLetter->getNum(), winnerLetter->getText().c_str());
		mu.unlock();//Разблокируем
	}

private:
	//Вектор указателей на Валентинки
	vector<Valentine*> letters;
	int winner;//Индекс победителя
	mutex mu;

};

/// <summary>
/// Логика работы каждого клиента, запускается для каждого в отдельном потоке
/// </summary>
/// <param name="roomNumber"></param>
/// <param name="text"></param>
/// <param name="server"></param>
void clientMain(int roomNumber, string text, Server* server)
{
	srand(time(NULL));
	printf("[CLIENT №%d] Начинаю писать письмо...\n", roomNumber);
	//Создаем письмо клиента
	Valentine letter(text, roomNumber);

	//Тратит время на написание письма
	this_thread::sleep_for(chrono::milliseconds(100+rand() % 1000));
	server->enqueueRequest(&letter);
	printf("[CLIENT №%d] Отправил письмо \"%s\", жду ответа!\n", roomNumber, text.c_str());

	//Активное ожидание, пока сервер не определил победителя поток будет ожидать
	while (!server->isResponseReady())
		this_thread::sleep_for(chrono::milliseconds(5));
	//Получаем ответ с сервера по нашему письму
	bool response = server->getResponse(&letter);
	//Выводим ответ
	if (response)
		printf("[CLIENT №%d] \tПолучил ответ.\tСчастливчик, сегодня тебя выбрали!\n", roomNumber);
	else
		printf("[CLIENT №%d] \tПолучил ответ.\tНет, студентка с тобой не идет!\n", roomNumber);
}

/// <summary>
/// Проверка ввода
/// </summary>
/// <returns></returns>
int EnterCheck()
{

	unsigned  int a;
	while (!(cin >> a) || (cin.peek() != '\n'))
	{
		cin.clear();
		while (cin.get() != '\n');
		printf("Ошибка ввода!\n");
		printf("Повторите ввод\n");
	}
	return a;
}

int main()
{
	setlocale(LC_ALL, "rus");
	srand(time(NULL));

	//Проверка ввода
	cout << "Оформите ввод количества валентинок:" << endl;
	int n=EnterCheck();

	while (n <= 0)
	{
		printf( "Введено отрицательное число или ноль\n");
		printf( "Повторите ввод\n");
		n = EnterCheck();
	}

	//Пожелания в валентинках
	string phrases[8] = { "Моему любимому хейтеру" ,
		"Сильнее пуджа я люблю только тебя",
		"Да, любил я сладко покодить, но больше всего я люблю тебя",
		"Любимка",
		"Дед мороз тебе свою любовь принес",
		"Я никогда не объявлю тебе забастовку",
		"Давай выходи",
		"Я твоё чудовище"
	};
	//Создаем указатель на сервер
	Server* server = new Server();
	
	//Создаем указатель на потоки 
	thread** clientThreads = new thread * [n];

	printf("Сервер запускается...\n");
	//Создаем и запускаем поток клиента
	thread serverThread([server] { server->serverMain(); });

	printf("Клиенты запускаются...\n");
	//Определяем и запускаем потоки клиентов метода clientMain
	for (int i = 0; i < n; i++)
	{
		clientThreads[i] = new thread(clientMain, i + 1, phrases[rand() % 8], server);
	}

	//Присоединяем потоки клиентов
	for (int i = 0; i < n; i++)
	{
		if (clientThreads[i]->joinable())
			clientThreads[i]->join();
	}

	//Присоединяем поток сервера
	if (serverThread.joinable())
		serverThread.join();

	delete server;
	delete []clientThreads;
	system("pause");
	return 0;
}
