# Курсовая работа на профессии "DevOps-инженер с нуля"-Абрамов Сергей

### Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud.

Примечание: в курсовой работе используется система мониторинга Prometheus. Вместо Prometheus вы можете использовать Zabbix. Задание для курсовой работы с использованием Zabbix находится по ссылке.

Перед началом работы над дипломным заданием изучите Инструкция по экономии облачных ресурсов.

### Инфраструктура

Для развёртки инфраструктуры используйте Terraform и Ansible.

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт

Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте Target Group, включите в неё две созданных ВМ.

Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.

Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт curl -v <публичный IP балансера>:80

### Мониторинг

Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и Nginx Log Exporter. Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые tresholds на соответствующие графики.

### Логи

Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть

Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно

Не входит в минимальные требования.

1. Для Prometheus можно реализовать альтернативный способ хранения данных — в базе данных PpostgreSQL. Используйте Yandex Managed Service for PostgreSQL. Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД.

2. Вместо конкретных ВМ, которые входят в target group, можно создать Instance Group, для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.

3. Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.

4. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.

5. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

### Выполнение работы

На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

⚠️ В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

Важно: Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

### Критерии сдачи

1. Инфраструктура отвечает минимальным требованиям, описанным в Задаче.

2. Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Grafanа).

3. Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.

4. Работа оформлена в отдельном репозитории в GitHub или в Google Docs, разрешён доступ по ссылке.

5. Код размещён в репозитории в GitHub.

6. Работа оформлена так, чтобы были понятны ваши решения и компромиссы.

7. Если использованы дополнительные репозитории, доступ к ним открыт.

### Как правильно задавать вопросы дипломному руководителю

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.

2. Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.

3. При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать здесь.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.

2. Откладывание выполнения дипломной работы на последний момент.

3. Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

---

### Выполнение курсового проекта

### Инфраструктура

Для развертывания использую terraform apply

![terraform apply](https://github.com/smabramov/Course-project/blob/9ec0972f43fc329deed56c2c0db00ea34286c257/jpg/diplom1.jpg)

Проверяю параметрвы созданных ВМ

![vm](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom2.jpg)

Устанавливаю Ansible на bastion host

![ansible](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom3.jpg)

Содержимое файлы inventory.ini (использовались fqdn имена)

![ini](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom4.jpg)

Проверяем доступность хостов с помощью Ansible ping

![ping](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom5.jpg)

### Сайт

Устанавливаем Nginx

![nginx](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom6.jpg)

Создайте Target Group, включите в неё две созданных ВМ.

![terget_group](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom7.jpg)

Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![Backend Group](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom8.jpg)

Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.

![router](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom9.jpg)

Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![balanser](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom10.jpg)

Протестируйте сайт curl -v <публичный IP балансера>:80

![curl](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom11.jpg)
![sait](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom12.jpg)

### Мониторинг

Zabbix доступен по http://158.160.12.87/zabbix/

Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix.

![install](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom13.jpg)
![install](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom14.jpg)
![zabbix](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom15.jpg)

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

![1](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom16.jpg)
![2](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom17.jpg)
![3](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom18.jpg)

### Логи

Kibana доступен по http://158.160.5.95:5601/

Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch

![install](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom19.jpg)
![install](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom20.jpg)

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

![1](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom22.jpg)
![2](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom23.jpg)
![]()

### Сеть

Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.

![security](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom24.jpg)

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Эта вм будет реализовывать концепцию bastion host . Синоним "bastion host" - "Jump host". Подключение ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью ProxyCommand . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Правило Bastion host

![rule](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom25.jpg)
![subnets](https://github.com/smabramov/Course-project/blob/4a8ed38bbac4bd3a584be048844e5ba4ec068a53/jpg/diplom26.jpg)

### Резервное копирование

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.


![1](https://github.com/smabramov/Course-project/blob/9b2547a236e450f9824d9f26ab158cd330f4a29b/jpg/diplom28.jpg)
![2]()