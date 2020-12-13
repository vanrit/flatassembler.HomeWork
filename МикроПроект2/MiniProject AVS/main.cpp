#include <pthread.h>
#include <string>
#include <semaphore.h>
#include <ctime>
#include <iostream>
#include <unistd.h>
#include <cstdio>

//Симонович Иван Сергеевич БПИ 193 Вариант 19
//19. Задача о Винни-Пухе - 3 или неправильные пчелы - 2. N пчел живет в
//улье, каждая пчела может собирать мед и сторожить улей (N>3). Ни одна
//пчела не покинет улей, если кроме нее в нем нет других пчел. Каждая пчела
//приносит за раз одну порцию меда. Всего в улей может войти тридцать
//порций меда. Вини-Пух спит пока меда в улье меньше половины, но как
//        только его становится достаточно, он просыпается и пытается достать весь
//мед из улья. Если в улье находится менее чем три пчелы, Вини-Пух забирает
//мед, убегает, съедает мед и снова засыпает. Если в улье пчел больше, они
//        кусают Вини-Пуха, он убегает, лечит укус, и снова бежит за медом. Создать
//        многопоточное приложение, моделирующее поведение пчел и медведя.

using namespace std;

// Вместимость буфера-улья
int maxHoney = 30;

// Кол-во пчел
int n;

//Количество попыток медведя добраться до улья и вытащить мед
int numberRetries;

// Кол-во меда
int honey = 0;

//  Количество пчел в улье, которые его сторожат
int beesCount;

// счетчики количества итераций в потоках
static int retrie = 0, flies = 0;

// Семафор semBear нужен для организации ожидания медведя до того момента, как улей будет полон на половину
sem_t semBear;

// Семафор semBee нужен, чтобы гарантировать, что пчелы не будут летать больше чем 30 раз при каждой попытке медведя
sem_t semBee;

static bool isAwake = false;//Проснулся ли уже мишка
static bool stop = true;//Флаг остановки

pthread_mutex_t mut1;//Мютексы для ограничения доступа к ресурсам
pthread_mutex_t mut2;


/// Метод потока медведя, в данной задаче медведь является потребителем с доп условием
/// \param param
/// \return
void *bear(void *param) {
    while (retrie < numberRetries) {
        pthread_mutex_lock(&mut2);
        //Если у семафора медведя есть положительное значение>0, то оно уменьшится на 1, если же оно не >0, то поток будет ожидать
        sem_wait(&semBear);

        if (beesCount >= 3) { //Если в улье находится менее чем три пчелы, Вини-Пух забирает мед, убегает
            //Если все таки в улье не находится менее трех пчел, то виннипуха кусают пчелы и он идет лечить
            printf("Time: %.3lf. Bear can't get %d honey. He must heal after fighting with bees. Bees in hive %d\n",
                   clock() / 1000.0, honey, beesCount);
            //Идет в берлогу спать
            sleep(3);
        } else {
            //Иначе, если в улье меньше чем 3 пчелы, то меведь заберет мед и напишет об этом
            printf("Time: %.3lf. Bear get %d honey. Bees in hive %d\n", clock() / 1000.0, honey, beesCount);
            honey = 0;  // Меведь съедает мед

        }
        // Увеличиваем значение семафора, тем самым разблокируем ожидающие потоки пчел
        for (int i = 0; i < maxHoney; i++) {
            sem_post(&semBee);
        }

        retrie++;

        //Медведь опять заснул
        printf("Time %.3lf. Bear is now sleeping. Zzzzz..... \n", clock() / 1000.0);
        isAwake = false;
        pthread_mutex_unlock(&mut2);
    }
    return nullptr;
}

/// Метод для потока n-ого количества пчел
/// \param param
/// \return
void *bee(void *param) {
    int cNum = *((int *) param); // номер пчелы

    while (stop) { //Проверка флага остановки

        while (beesCount <= 1) sleep(1);// В улье должна остатся хотя бы одна пчела


        if (flies < numberRetries * maxHoney) { //Проверяем чтобы полетов пчел не было больше чем нужно

            sem_wait(&semBee);// Если у семафора пчелы есть положительное значение>0, то оно уменьшится на 1,
            // иначе поток будет ожидать

            pthread_mutex_lock(&mut1);
            beesCount--; //Уменьшаем количество пчел, т.к. одна улетела
            pthread_mutex_unlock(&mut1);

            // время на полет пчелы за медом
            sleep((rand() + cNum) % 5);

            printf("Time: %.3lf. Bee num %d fly to search some honey. \t|%d honey and %d bees in the hive|\n",
                   clock() / 1000.0, cNum, honey, beesCount);

            // время на полет пчелы обратно
            sleep((rand() + cNum) % 5);


            pthread_mutex_lock(&mut1);
            if (honey < 30) honey++; //Пчела приносет мед, проверка, что хранилище не заполнено
            beesCount++;//Пчела прилетела
            printf("Time: %.3lf. Bee num %d add honey. \t|Now %d honey and %d bees in the hive|\n", clock() / 1000.0,
                   cNum, honey, beesCount);

            pthread_mutex_unlock(&mut1);


            //Проверка условия заполненности, чтобы медведь проснулся
            if (honey >= 15 && !isAwake && retrie < numberRetries) {
                printf("Time %.3lf. The bear is awake %d honey in the hive\n", clock() / 1000.0, honey);
                isAwake = true;
                sem_post(&semBear); // Увеличиваем значение семафора для потока меведя, тем самым снимая с него блок
            }

            flies++;

            if (retrie == numberRetries)
                break; //После того,как меведь тратит все свои попытки пчелы начинают отдыхать в улье



            //Время на отдых
            sleep(1);
        } else {
            stop = false;
        }

    }
    return nullptr;
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
        printf("Input error!\n");
        printf("Repeat the input\n");
    }
    return a;
}

/// Проверка поподания в диапазон
/// \param a
/// \param b
/// \return
int checkRange(int a, int b) {
    int num = EnterCheck();
    while (num <= a || num > b) {
        printf("Entered number is greater than %d or less than %d\n", b, a + 1);
        printf("Repeat the input\n");
        num = EnterCheck();
    }

    return num;
}

int main() {

    srand(time(NULL));

    //Проверка ввода
    printf("Enter the number number of bees:\n");
    n = checkRange(3, 30);//Количество пчел по условию больше 3
    // Т.к. медведь заберет мед только, если в улье <3 пчелы, то разумно ввести ограничение на 30 пчел, чтобы их не было уж слишком много в улье
    beesCount = n;

    printf("Enter the number of times bear coming for honey:\n");
    numberRetries = checkRange(0, 20);//Количество попыток медведя забрать мед у пчел

    //Мютексы
    pthread_mutex_init(&mut2, nullptr);
    pthread_mutex_init(&mut1, nullptr);

    sem_init(&semBear, 0, 0);// семафор медведя инициализируем 0 значением, так как для него есть доп условие
    sem_init(&semBee, 0, 30);//Для полного заполнения улья

    //Поток медведя
    pthread_t bearThread;
    pthread_create(&bearThread, nullptr, bear, (void *) nullptr);

    // Создаю n потоков для пчел
    pthread_t beeThreads[n];
    int num[n];//Порядковые номера

    for (int i = 0; i < n; i++) {
        num[i] = i + 1;
        pthread_create(&beeThreads[i], nullptr, bee, (void *) (num + i));
    }

    //Ожидание завершения всех созданных потоков
    pthread_join(bearThread, NULL);

    for (auto t: beeThreads) {
        pthread_join(t, NULL);
    }

    //Уничтожаем семафоры
    sem_destroy(&semBear);
    sem_destroy(&semBee);

    system("pause");
    return 0;
}
