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

//Активная блокировка
bool ready = false;
std::mutex mu;
std::condition_variable cv;


//Класс, где содержится логика сервера-студентки
class Server
{
public:
	Server()
	{
		size = 0;
	}

	Server(size_t length)
	{
		cout << "[SERVER] Настало новое утро. Жду валентинок." << endl;
		size = length;
	}

	void Start()
	{
		this_thread::sleep_for(chrono::milliseconds(10000));
		Proc();
	}

	/// <summary>
	/// Логика отправки и обработки сообщения от клиента
	/// </summary>
	/// <param name="from"></param>
	/// <param name="i"></param>
	void SendMessage(string message)
	{
		counter++;
	}

	/// <summary>
	/// Проверить это ли номер победителя
	/// </summary>
	/// <param name="number"></param>
	/// <returns></returns>
	bool GetWinner(int number)
	{
		return (number == winner);
	}

	/// <summary>
	/// Все ли запросы отправлены
	/// </summary>
	/// <returns></returns>
	bool IsReady()
	{
		return(counter == size);
	}

private:
	/// <summary>
	/// Студентка выбирает счастливчика
	/// </summary>
	void Proc()
	{
		srand(time(NULL));
		winner = rand() % size;
		cout << "[SERVER] Избран из комнаты " << winner+1 << endl;
		ready = true;
		cv.notify_all();
	}

	size_t size;
	int winner = -1;
	int counter = 0;
};

//Класс клиент-валентинки
class Valentine
{
public:
	Valentine()
	{
		text = "";
	}

	/// <summary>
	/// Присоединяем поток
	/// </summary>
	void End()
	{
		if (th.joinable())
			th.join();
	}

	Valentine(const string& text, Server& server)
	{
		this->text = text;
		this->server = server;
	}

	string GetText()
	{
		return text;
	}

	void SetNum(int i)
	{
		num = i;
	}

	int GetNum()
	{
		return num;
	}

	void Info()
	{
		srand(time(NULL));
		this_thread::sleep_for(chrono::milliseconds(20) * (rand() % 10));

		std::unique_lock<std::mutex> lck(mu);

		//cout << "[Client № " << num + 1 << "]"<<"\tОтправил запрос на сервер."<<endl;

		server.SendMessage(text);

		//this_thread::sleep_for(chrono::milliseconds(20) * (rand() % 10));

		//Если стоит блокировка, то поток будет ждать, пока её снимут
		while (!ready)
			cv.wait(lck);
			//this_thread::sleep_for(chrono::milliseconds(1));

		cout << "[Client № "<<num+1<<"]";

		if (!server.GetWinner(num))
			cout << "Нет, студентка с тобой не идет. ";
		else
			cout << "Счастливчик, сегодня тебя выбрали! ";
		cout << " \tТвоя валентинка: \t" << text << endl;
	}

	void Start()
	{
		//Определяем поток
		th= thread(&Valentine::Info, this);
	}
private:
	int num = 0;
	string text;
	//Сервер клиента
	Server server;
	//Поток
	thread th;
};

int EnterCheck()
{

	unsigned  int a;
	while (!(cin >> a) || (cin.peek() != '\n'))
	{
		cin.clear();
		while (cin.get() != '\n');
		cout << "Ошибка ввода!" << endl;
		cout << "Повторите ввод" << endl;
	}
	return a;
}

int main()
{
	setlocale(LC_ALL, "rus");
	srand(time(NULL));

	cout << "Оформите вкид количества валентинок:" << endl;
	int n=EnterCheck();

	while (n <= 0)
	{
		cout << "Введено отрицательное число или ноль"<<endl;
		cout << "Повторите ввод" << endl;
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

	//Контейнер валентинок
	vector <Valentine> lovers(0);

	//Сервер
	Server serv(n);

	//В каждую влентинку-клиента записываем случайное пожелание и присваиваем номер
	for (size_t i = 0; i < n; i++)
	{
		lovers.push_back(Valentine(phrases[rand() % 8], serv));
		lovers[i].SetNum(i);
	}

	serv.Start();
	//Запускаем потоки клиентов на сервер
	for (int i = 0; i < lovers.size(); i++)
	{
		cout << "[Client № " << i + 1 << "]" << "\tОтправил запрос на сервер." << endl;
		lovers[i].Start();
	}

	//Join для каждого открытого потока
	for (int i = 0; i < lovers.size(); i++)
	{
		lovers[i].End();
	}

}
