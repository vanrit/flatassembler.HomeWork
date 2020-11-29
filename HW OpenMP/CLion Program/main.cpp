#include <iostream>
#include <omp.h>
#include <chrono>
#include <vector>
#include <unistd.h>
#include <windows.h>


//Симонович Иван Сергеевич БПИ 193 Вариант 19
using namespace std;


//Класс, где хранится информация о клиенте-валентинке
class Valentine {
public:
    Valentine() {
        text = "";
    }

    Valentine(const string &text, int &num) {
        this->text = text;//Текст валентинки
        this->num = num;//Номер комнаты из который пришла валентинка
    }

    /// <summary>
    /// Получаем Текст
    /// </summary>
    /// <returns></returns>
    string getText() {
        return text;
    }

    /// <summary>
    /// Получаем номер
    /// </summary>
    /// <returns></returns>
    int getNum() {
        return num;
    }

private:
    int num = 0;
    string text;
};

//Класс, где содержится логика сервера-студентки
class Server {
public:

    Server(int &size) {
        this->size = size;//Количество пользователей сервера
        winner = -1;//Победитель пока не определен
    }

    /// <summary>
    /// Отправка сообщений клиентом на сервер
    /// В ответ клиент получает номер своего сообщения
    /// </summary>
    /// <param name="letter">письмо клиента</param>
    int enqueueRequest(Valentine *letter) {
        letters.push_back(letter);
        return ++count;//Увеличиваем счетчик сообщений
    }

    /// <summary>
    /// Проверка определен ли победитель
    /// </summary>
    /// <returns></returns>
    bool isResponseReady() {
        return winner != -1;
    }

    /// <summary>
    /// Сервер отправляет ответ клиенту
    /// Является ли его письмо выигрышным
    /// </summary>
    /// <param name="letter">письмо</param>
    /// <returns></returns>
    bool getResponse(Valentine *letter) {
        count--;//Уменьшаем счетчик, так как клиент получил ответ
        int letterIndex = -2;
        for (int i = 0; i < letters.size(); i++) {
            //Находим индекс введеного письма из поступивших
            if (letters[i] == letter) {
                letterIndex = i;
                break;
            }
        }
        //Сравниваем с выигрышным индексом
        bool response = (letterIndex == winner);
        return response;
    }

    /// <summary>
    /// Основная логика работы сервера, запускается в потоке
    /// </summary>
    void serverMain() {
        srand(time(NULL));
        printf("[SERVER] Начался новый день. Жду, пока утро закончится.\n");

        //Задержка перед определением победителя на сервере клиента, нужна чтобы все клиенты отправили данные
        while (size > count) {
            sleep(1);
        }

        printf("[SERVER] Утро закончилось. Получено %d писем.\n", (int) letters.size());
        winner = rand() % letters.size(); //Определяем индекс победителя, после этого isResponseReady вернет true
        //Указатель на письмо победителей
        Valentine *winnerLetter = letters[winner];

        //Вывод инфы о победителе
        printf("[SERVER] Победило письмо номер %d из комнаты %d с текстом \"%s\".\n", winner + 1,
               winnerLetter->getNum(), winnerLetter->getText().c_str());

        //Проверка, что все клиенты получили информацию, после чего сервер прекращает работу
        while (count > 0)
            sleep(1);
    }

private:
    //Вектор указателей на Валентинки
    vector<Valentine *> letters;
    int winner;//Индекс победителя
    int size = 0;//Количество клиентов сервера
    int count = 0;//Счетчик запросов
};

/// <summary>
/// Логика работы каждого клиента, запускается для каждого клиента в отдельном потоке
/// </summary>
/// <param name="roomNumber"></param>
/// <param name="text"></param>
/// <param name="server"></param>
void clientMain(int roomNumber, string text, Server *server) {
    //Обновляем радном, чтобы для каждого потока был свой
    srand(roomNumber + text.length());
    printf("[CLIENT №%d] Начинаю писать письмо...\n", roomNumber);
    //Создаем письмо клиента
    Valentine letter(text, roomNumber);


    //Тратит псевдослучайное время на написание письма
    sleep(rand() % 3);

    int letterNumber = server->enqueueRequest(&letter);//Клиент отправляет валентинку на сервер
    printf("[CLIENT №%d] Отправил письмо %d \"%s\", жду ответа!\n", roomNumber, letterNumber,
           text.c_str());//Выводит информацию об этом запросе

    //Активное ожидание, пока сервер не определил победителя поток будет ожидать
    while (!server->isResponseReady())
        sleep(1);

    //Получаем ответ с сервера по нашей валентинке, является ли клиент победителем
    bool response = server->getResponse(&letter);
    //Выводим ответ в клиенте
    if (response)
        printf("[CLIENT №%d] \tПолучил ответ.\tСчастливчик, сегодня тебя выбрали!\n", roomNumber);
    else
        printf("[CLIENT №%d] \tПолучил ответ.\tНет, студентка с тобой не идет!\n", roomNumber);
}

/// <summary>
/// Проверка ввода
/// </summary>
/// <returns></returns>
int EnterCheck() {
    int a;
    while (!(cin >> a) || (cin.peek() != '\n')) {
        cin.clear();
        while (cin.get() != '\n');
        printf("Ошибка ввода!\n");
        printf("Повторите ввод\n");
    }
    return a;
}

int main() {
    SetConsoleOutputCP(1251);
    srand(time(NULL));

    //Проверка ввода
    printf("Оформите ввод количества валентинок:\n");
    int n = EnterCheck();

    while (n <= 0 || n > 250) {
        printf("Введено отрицательное число, ноль или число большее чем 250\n");
        printf("Повторите ввод\n");
        n = EnterCheck();
    }

    //Пожелания в валентинках
    string phrases[8] = {"Моему любимому хейтеру",
                         "Сильнее пуджа я люблю только тебя",
                         "Да, любил я сладко покодить, но больше всего я люблю тебя",
                         "Любимка",
                         "Дед мороз тебе свою любовь принес",
                         "Я никогда не объявлю тебе забастовку",
                         "Давай выходи",
                         "Я твоё чудовище"
    };

    //Создаем указатель на сервер
    Server *server = new Server(n);

#pragma omp parallel num_threads(n+1)//Выделяем n+1 поток n для клиентов-поколонников и 1 для сервера-студентки
    {
        if (omp_get_thread_num() == 0) {
            printf("Сервер запускается...\n");
            server->serverMain();//Запускаем метод сервера
            printf("Сервер засыпает, спят усталые игрушки, клиенты спят\n");
        } else {
            //Запускаем метод в потоке каждого из n клиентов от (1 до n+1)
            clientMain(omp_get_thread_num(), phrases[(rand() + omp_get_thread_num()) % 8], server);
        }
    }

    delete server;//Очищаем память во избежании утечек
    system("pause");
    return 0;
}
