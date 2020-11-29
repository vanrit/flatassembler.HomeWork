#include <iostream>
#include <omp.h>
#include <chrono>
#include <vector>
#include <unistd.h>
#include <windows.h>


//��������� ���� ��������� ��� 193 ������� 19
using namespace std;


//�����, ��� �������� ���������� � �������-����������
class Valentine {
public:
    Valentine() {
        text = "";
    }

    Valentine(const string &text, int &num) {
        this->text = text;//����� ����������
        this->num = num;//����� ������� �� ������� ������ ����������
    }

    /// <summary>
    /// �������� �����
    /// </summary>
    /// <returns></returns>
    string getText() {
        return text;
    }

    /// <summary>
    /// �������� �����
    /// </summary>
    /// <returns></returns>
    int getNum() {
        return num;
    }

private:
    int num = 0;
    string text;
};

//�����, ��� ���������� ������ �������-���������
class Server {
public:

    Server(int &size) {
        this->size = size;//���������� ������������� �������
        winner = -1;//���������� ���� �� ���������
    }

    /// <summary>
    /// �������� ��������� �������� �� ������
    /// � ����� ������ �������� ����� ������ ���������
    /// </summary>
    /// <param name="letter">������ �������</param>
    int enqueueRequest(Valentine *letter) {
        letters.push_back(letter);
        return ++count;//����������� ������� ���������
    }

    /// <summary>
    /// �������� ��������� �� ����������
    /// </summary>
    /// <returns></returns>
    bool isResponseReady() {
        return winner != -1;
    }

    /// <summary>
    /// ������ ���������� ����� �������
    /// �������� �� ��� ������ ����������
    /// </summary>
    /// <param name="letter">������</param>
    /// <returns></returns>
    bool getResponse(Valentine *letter) {
        count--;//��������� �������, ��� ��� ������ ������� �����
        int letterIndex = -2;
        for (int i = 0; i < letters.size(); i++) {
            //������� ������ ��������� ������ �� �����������
            if (letters[i] == letter) {
                letterIndex = i;
                break;
            }
        }
        //���������� � ���������� ��������
        bool response = (letterIndex == winner);
        return response;
    }

    /// <summary>
    /// �������� ������ ������ �������, ����������� � ������
    /// </summary>
    void serverMain() {
        srand(time(NULL));
        printf("[SERVER] ������� ����� ����. ���, ���� ���� ����������.\n");

        //�������� ����� ������������ ���������� �� ������� �������, ����� ����� ��� ������� ��������� ������
        while (size > count) {
            sleep(1);
        }

        printf("[SERVER] ���� �����������. �������� %d �����.\n", (int) letters.size());
        winner = rand() % letters.size(); //���������� ������ ����������, ����� ����� isResponseReady ������ true
        //��������� �� ������ �����������
        Valentine *winnerLetter = letters[winner];

        //����� ���� � ����������
        printf("[SERVER] �������� ������ ����� %d �� ������� %d � ������� \"%s\".\n", winner + 1,
               winnerLetter->getNum(), winnerLetter->getText().c_str());

        //��������, ��� ��� ������� �������� ����������, ����� ���� ������ ���������� ������
        while (count > 0)
            sleep(1);
    }

private:
    //������ ���������� �� ����������
    vector<Valentine *> letters;
    int winner;//������ ����������
    int size = 0;//���������� �������� �������
    int count = 0;//������� ��������
};

/// <summary>
/// ������ ������ ������� �������, ����������� ��� ������� ������� � ��������� ������
/// </summary>
/// <param name="roomNumber"></param>
/// <param name="text"></param>
/// <param name="server"></param>
void clientMain(int roomNumber, string text, Server *server) {
    //��������� ������, ����� ��� ������� ������ ��� ����
    srand(roomNumber + text.length());
    printf("[CLIENT �%d] ������� ������ ������...\n", roomNumber);
    //������� ������ �������
    Valentine letter(text, roomNumber);


    //������ ��������������� ����� �� ��������� ������
    sleep(rand() % 3);

    int letterNumber = server->enqueueRequest(&letter);//������ ���������� ���������� �� ������
    printf("[CLIENT �%d] �������� ������ %d \"%s\", ��� ������!\n", roomNumber, letterNumber,
           text.c_str());//������� ���������� �� ���� �������

    //�������� ��������, ���� ������ �� ��������� ���������� ����� ����� �������
    while (!server->isResponseReady())
        sleep(1);

    //�������� ����� � ������� �� ����� ����������, �������� �� ������ �����������
    bool response = server->getResponse(&letter);
    //������� ����� � �������
    if (response)
        printf("[CLIENT �%d] \t������� �����.\t�����������, ������� ���� �������!\n", roomNumber);
    else
        printf("[CLIENT �%d] \t������� �����.\t���, ��������� � ����� �� ����!\n", roomNumber);
}

/// <summary>
/// �������� �����
/// </summary>
/// <returns></returns>
int EnterCheck() {
    int a;
    while (!(cin >> a) || (cin.peek() != '\n')) {
        cin.clear();
        while (cin.get() != '\n');
        printf("������ �����!\n");
        printf("��������� ����\n");
    }
    return a;
}

int main() {
    SetConsoleOutputCP(1251);
    srand(time(NULL));

    //�������� �����
    printf("�������� ���� ���������� ����������:\n");
    int n = EnterCheck();

    while (n <= 0 || n > 250) {
        printf("������� ������������� �����, ���� ��� ����� ������� ��� 250\n");
        printf("��������� ����\n");
        n = EnterCheck();
    }

    //��������� � �����������
    string phrases[8] = {"����� �������� �������",
                         "������� ����� � ����� ������ ����",
                         "��, ����� � ������ ��������, �� ������ ����� � ����� ����",
                         "�������",
                         "��� ����� ���� ���� ������ ������",
                         "� ������� �� ������� ���� ����������",
                         "����� ������",
                         "� ��� ��������"
    };

    //������� ��������� �� ������
    Server *server = new Server(n);

#pragma omp parallel num_threads(n+1)//�������� n+1 ����� n ��� ��������-������������ � 1 ��� �������-���������
    {
        if (omp_get_thread_num() == 0) {
            printf("������ �����������...\n");
            server->serverMain();//��������� ����� �������
            printf("������ ��������, ���� ������� �������, ������� ����\n");
        } else {
            //��������� ����� � ������ ������� �� n �������� �� (1 �� n+1)
            clientMain(omp_get_thread_num(), phrases[(rand() + omp_get_thread_num()) % 8], server);
        }
    }

    delete server;//������� ������ �� ��������� ������
    system("pause");
    return 0;
}
