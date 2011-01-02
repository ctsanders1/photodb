unit Language;
                                                                          
interface

uses
  uConstants;

Const

 TEXT_MES_WARNING = 'Внимание';
 
 TEXT_MES_UNKNOWN_ERROR_F = 'Непредвиденная ошибка! %s';
 TEXT_MES_CONFIRM = 'Подтверждение';
 TEXT_MES_QUESTION = 'Вопрос';
 TEXT_MES_FILE_EXISTS = 'Файл с таким именем уже существует! Заменить?';
 TEXT_MES_FILE_EXISTS_1 = 'Файл %s уже существует!'+#13+'Заменить?';
 TEXT_MES_KEY_SAVE = 'Ключ для активации сохранён! Перезапустите приложение для результата!';
 TEXT_MES_DIR_NOT_FOUND = 'Невозможно найти директорию:'+#13+'%s';
 TEXT_MES_DB_FILE_NOT_VALID = 'Данный файл не является корректным файлом PhotoDB!';
 TEXT_MES_DIR_CR_FAILED = 'Невозможно создать директорию'+#13+'%s'+#13+'Пожалуйста, выберите другую директорию';
 TEXT_MES_WAIT_FOR_A_MINUTE = 'Пожалуйста, подождите минуту...';
 TEXT_MES_READING_DB = 'Чтение базы данных...';
 TEXT_MES_READING_GROUPS_DB = 'Чтение базы данных групп';
 TEXT_MES_QUERY_EX = 'Запрос выполняется... ';

 TEXT_MES_INITIALIZATION = 'Инициализация';
 TEXT_MES_SIZE = 'Размер';

 TEXT_MES_ID = 'ID';
 TEXT_MES_RATING = 'Оценка';
 TEXT_MES_NAME = 'Имя';
 TEXT_MES_FULL_PATH = 'Полное имя';
 TEXT_MES_WIDTH = 'Ширина';
 TEXT_MES_HEIGHT = 'Высота';
 TEXT_MES_PROGRESS_PR = 'Выполнение... (&%%)';
 TEXT_MES_LOAD_QUERY_PR = 'Загрузка запроса... (&%%)';
 TEXT_MES_SEARCH_FOR_REC_FROM = 'Всего %s записей...';

 TEXT_MES_SERCH_PR = 'Пожалуйста, подождите пока выполняется поиск...';
 TEXT_MES_OPTIONS = 'Настройки';

 TEXT_MES_CLEAR = 'Очистить';
 TEXT_MES_CLOSE = 'Закрыть';
 TEXT_MES_SHOW_PREVIEW = 'Показывать предпросмотр';
 TEXT_MES_HINTS = 'Предпросмотр';
 TEXT_MES_ANIMATE_SHOW = 'Анимированный показ';
 TEXT_MES_SHOW_SHADOW = 'Показ тени';
 TEXT_MES_OK = 'Да';
 TEXT_MES_CANCEL = 'Отмена';
 TEXT_MES_SHELL_EXTS = 'Расширения:';
 TEXT_MES_SHOW_CURRENT_OBJ = 'Показывать текущие объекты:';
 TEXT_MES_FOLDERS = 'Папки';
 TEXT_MES_SIMPLE_FILES = 'Простые фалы';
 TEXT_MES_IMAGE_FILES = 'Изображения';
 TEXT_MES_HIDDEN_FILES = 'Скрытые файлы';
 TEXT_MES_TH_OPTIONS = 'Опции предпросмотров:';
 TEXT_MES_SHOW_ATTR = 'Показывать атрибуты';
 TEXT_MES_SHOW_TH_FOLDRS = 'Показывать предпросмотр для папок';
 TEXT_MES_SAVE_TH_FOLDRS = 'Сохранять предпросмотр для папок';
 TEXT_MES_SHOW_TH_IMAGE = 'Показывать предпросмотр для изображений';
 TEXT_MES_CLEANING_ITEM = 'Очистка... [%s]';
 TEXT_MES_CLEANING_STOPED = 'Очистка остановлена';

 TEXT_MES_PIXEL_FORMAT_D = '%dpx.';
 TEXT_MES_CREATING = 'Создание';
 TEXT_MES_UNABLE_SHOW_FILE = 'Невозможно отобразить файл:';
 TEXT_MES_NO_DB_FILE = '<нет файла>';
 TEXT_MES_OPEN = 'Открыть';
 TEXT_MES_CREATE_NEW = 'Создать новую';
 TEXT_MES_EXIT = 'Выход';
 TEXT_MES_USE_AS_DEFAULT_DB = 'Использовать БД по умолчанию';
 TEXT_MES_SELECT_DATABASE = 'Выбрать БД';
 TEXT_MES_NEW_DB_SIZE_FORMAT = 'Размер новой базы (ориентировочно) = %s';
 TEXT_MES_NEW_DB_SIZE_FORMAT_10000 = 'Размер новой базы (ориентировочно для 10000 записей) = %s';
 TEXT_MES_RATING_FORMATA = 'Оценка = %s';
 TEXT_MES_ID_FORMATA = 'ID = %s';
 TEXT_MES_DIMENSIONS = 'Разрешение : %s x %s';
 TEXT_MES_UPDATING_REC_FORMAT = 'Запись №%s [%s]';
 TEXT_MES_PAUSED = 'Пауза...';
 TEXT_MES_RENAME = 'Переименовать';
 TEXT_MES_DEL_FROM_DB_CONFIRM = 'Вы действительно хотите удалить эту информацию из БД?';
 TEXT_MES_PROGRAM_CODE = 'Код вашей копии программы:';
 TEXT_MES_ACTIVATION_NAME = 'Имя для активации:';
 TEXT_MES_ACTIVATION_KEY = 'Введите сюда ключ для активации:';
 TEXT_MES_SET_CODE = 'Установить код';
 TEXT_MES_ACTIVATION_CAPTION = 'Активация';
 TEXT_MES_CLOSE_FORMAT = 'Закрыть [%s]';
 TEXT_MES_REG_TO = 'Зарегистрировано на:';
 TEXT_MES_COPY_NOT_ACTIVATED = '<Копия не активирована>';
 TEXT_MES_ADDFILE = 'Добавить файл';

 TEXT_MES_IMAGE_PRIVIEW = 'Предпросмотр:';
 TEXT_MES_TASKS = 'Задачи';
 TEXT_MES_DELETE = 'Удалить';

 TEXT_MES_ADD_FOLDER = 'Добавить папку';
 TEXT_MES_FILE = 'Файл';
 TEXT_MES_FILE_NAME = 'Имя файла';

 TEXT_MES_BACK = 'Назад';
 TEXT_MES_NEXT = 'Следующий';

 TEXT_MES_TOOLS = 'Модули';

 TEXT_MES_NO_FILE = '<нет файла>';
 TEXT_MES_SEL_FOLDER_DB_FILES = 'Выберите папку к файлам БД';
 TEXT_MES_SEL_FOLDER_INSTALL = 'Выберите установочную директорию ';
 TEXT_MES_ENTER_NAME = 'Введите ваше имя';
 TEXT_MES_NAMEA = '<имя>';
 TEXT_MES_SUPPORTED_TYPES = 'Поддерживаемые типы файлов:';
 TEXT_MES_SUPPORTED_TYPES_CHECKED = '- Файл будет открываться с помощью PhotoDB';
 TEXT_MES_SUPPORTED_TYPES_GRAYED = '- Будет добавлен пункт для запуска';
 TEXT_MES_SUPPORTED_TYPES_UNCHECKED = '- Расширение не регистрируется';

 TEXT_MES_CHECK_ALL = 'Выбрать всё';
 TEXT_MES_UNCHECK_ALL = 'Отменить все';
 TEXT_MES_DEFAULT = 'По умолчанию';
 TEXT_MES_EXIT_SETUP = 'Выход';

 TEXT_MES_ADDING_FILE_PR = 'Добавление файлов... (&%%)';
 TEXT_MES_NOW_FILE = '<текущий файл>';
 TEXT_MES_NO_FILE_TO_ADD = 'Нет файлов для добавления';
 TEXT_MES_PAUSE = 'Пауза';
 TEXT_MES_UNPAUSE = 'Запустить';
 TEXT_MES_BREAK_BUTTON = 'Прервать!';
 TEXT_MES_FILL = 'Нет';
 TEXT_MES_AUTO = 'Автоматически';
 TEXT_MES_REPLACE_ALL = 'Заменять все';
 TEXT_MES_ADD_ALL = 'Добавить все';
 TEXT_MES_SKIP_ALL = 'Пропустить все';
 TEXT_MES_ASK_ABOUT_DUBLICATES = 'Сообщать о дубликатах';
 TEXT_MES_NEEDS_ACTIVATION = 'Необходима активизация программы';
 TEXT_MES_LIMIT_RECS = 'Вы работаете в неактивированной БД!'+#13+'Вы можете добавить только %s записей!'+#13+'Выберите "Справка" в меню в окне поиска"';
 TEXT_MES_LIMIT_TIME_END = 'Время работы программы истекло! Вы должны активизировать данную копию!';

 TEXT_MES_DB_OPTIONS = 'Настройки БД';
 TEXT_MES_PACK_TABLE = 'Упаковать БД';
 TEXT_MES_EXPORT_TABLE = 'Экспортировать';
 TEXT_MES_IMPORT_TABLE = 'Импортировать';

 TEXT_MES_CURRENT_DATABASE = 'Текущая БД';
 TEXT_MES_FILEA = '<файл>';
 TEXT_MES_NO_FILEA = '<нет файла>';
 TEXT_MES_DB_FILE_MANAGER = 'Изменение файла БД';
 TEXT_MES_GO_TO_REC_ID = 'Перейти к записи с ID';
 TEXT_MES_MANAGER_DB_CAPTION = 'Управление БД';
 TEXT_MES_PACKING_MAIN_DB_FILE = 'Упаковка файлов БД...';
 TEXT_MES_PACKING_GROUPS_DB_FILE = 'Упаковка файла с группами...';
 TEXT_MES_PACKING_END = 'Упаковка закончена...';
 TEXT_MES_WELCOME_FORMAT = 'Добро пожаловать в %s!';
 TEXT_MES_PACKING_BEGIN = 'Упаковка началась...';
 TEXT_MES_PACKING_TABLE = 'Упаковка таблицы:';
 TEXT_MES_CMD_CAPTION = 'Окно команд';
 TEXT_MES_CMD_TEXT = 'Подождите пока программа выполнит операцию...';
 TEXT_MES_EXPORT_WINDOW_CAPTION = 'Экспорт таблицы';
 TEXT_MES_EXPORT_PRIVATE = 'Экспорт личных записей';
 TEXT_MES_EXPORT_ONLY_RATING = 'Экспорт только записей с оценкой';
 TEXT_MES_EXPORT_REC_WITHOUT_FILES = 'Экспорт записей без файлов';
 TEXT_MES_EXPORT_GROUPS = 'Экспортировать группы';
 TEXT_MES_BEGIN_EXPORT = 'Начать экспорт';
 TEXT_MES_REC = 'Запись';
 TEXT_MES_REC_FROM_RECS_FORMAT = 'Запись #%s из %s';
 TEXT_MES_CLEANING_CAPTION = 'Очистка';
 TEXT_MES_DELETE_NOT_VALID_RECS = 'Удалять ненужные записи';
 TEXT_MES_VERIFY_DUBLICATES = 'Проверять дубликаты';
 TEXT_MES_MARK_DELETED_FILES = 'Помечать удалённые файлы';
 TEXT_MES_ALLOW_AUTO_CLEANING = 'Позволить автоочистку';
 TEXT_MES_STOP_NOW = 'Остановить';
 TEXT_MES_START_NOW = 'Начать';
 TEXT_MES_IMPORTING_CAPTION = 'Импорт БД';
 TEXT_MES_RECS_ADDED = 'Записей добавлено:';
 TEXT_MES_RECS_UPDATED = 'Записей обновлено:';
 TEXT_MES_RECS_ADDED_PR = '&%% (Добавлено)';
 TEXT_MES_RECS_UPDATED_PR = '&%% (Обновлено)';
 TEXT_MES_STATUS = 'Статус';
 TEXT_MES_STATUSA = '<Статус>';
 TEXT_MES_CURRENT_ACTION = 'Текущее действие';
 TEXT_MES_ACTIONA = '<Действие';
 TEXT_MES_MAIN_DB_AND_ADD_SAME = 'Главная и добавочная БД совпадают!';
 TEXT_MES_MAIN_DB_RECS_FORMAT = 'Главная БД (%s Rec)';
 TEXT_MES_ADD_DB_RECS_FORMAT = 'Добавочная БД (%s Rec)';
 TEXT_MES_RES_DB_RECS_FORMAT = 'Результирующая БД (%s Rec)';
 TEXT_MES_ADD_NEW_RECS = 'Добавлять новые записи';
 TEXT_MES_ADD_REC_WITHOUT_FILES = 'Добавлять записи без файлов';
 TEXT_MES_ADD_RATING = 'Добавлять оценку';
 TEXT_MES_ADD_ROTATE = 'Добавлять поворот';
 TEXT_MES_ADD_PRIVATE = 'Добавлять личные';
 TEXT_MES_ADD_KEYWORDS = 'Добавлять ключевыые слова';
 TEXT_MES_ADD_GROUPS = 'Добавлять группы';
 TEXT_MES_ADD_NIL_COMMENT = 'Добавлять пустые комментарии';
 TEXT_MES_ADD_COMMENT = 'Добавлять комментарии';
 TEXT_MES_ADD_NAMED_COMMENT = 'Добавлять именованые комментарии';
 TEXT_MES_ADD_DATE = 'Добавлять дату';
 TEXT_MES_ADD_LINKS = 'Добавлять ссылки';
 TEXT_MES_IGNORE_KEYWORDS = 'Игнорировать слова';
 TEXT_MES_IMPORTING_OPTIONS_CAPTION = 'Настройки импорта';
 TEXT_MES_REPLACE_GROUP_BOX = 'Заменить';
 TEXT_MES_ON__REPLACE_ = 'на';
 TEXT_MES_USE_CURRENT_DB = 'Использовать текущую БД';
 TEXT_MES_USE_ANOTHER_DB = 'Использовать другую БД';
 TEXT_MES_MAIN_DB = 'Главная БД';
 TEXT_MES_ADD_DB = 'Добавочная БД';
 TEXT_MES_RES_DB = 'Результирующая БД';
 TEXT_MES_BY_AUTHOR = 'Автор';
 TEXT_MES_LIST_IGNORE_WORDS = 'Список игнорируемых слов:';

 TEXT_MES_DELETE_ITEM = 'Удалить';

 TEXT_MES_DELETE_FROM_LIST = 'Удалить элемент из списка';
 TEXT_MES_ABORT = 'Прервать';
 TEXT_MES_SAVING_IN_PROGRESS = 'Сохранение выполняется...';
 TEXT_MES_SAVING_DATASET_CAPTION = 'Сохранение результатов';
 TEXT_MES_SAVING_GROUPS = 'Сохранение групп';
 TEXT_MES_FILE_ONLY_MDB = '<Выбеерите файл если хотите импортировать данные>';
 TEXT_MES_HELP_NO_RECORDS_IN_DB_FOUND = 'Если Вы хотите добавить изображения в БД, выберите "Проводник" в контекстном меню';
 TEXT_MES_HELP_HINT = 'Помощь';
 TEXT_MES_ALLOW_FAST_CLEANING = 'Разрешить быструю очистку';

 TEXT_MES_DONT_USE_EXT = 'Не использовать это расширение';
 TEXT_MES_USE_THIS_PROGRAM = 'Использовать эту программу по умолчанию';
 TEXT_MES_USE_ITEM = 'Использовать пункт в меню';

 TEXT_MES_CONVERTING = 'Обработка... (&%%)';

 TEXT_MES_CHOOSE_ACTION = 'Выберите необходимое действие';
 TEXT_MES_PATH = 'Размещение';
 TEXT_MES_CURRENT_FILE_INFO = 'Текущая информация по файлу';
 TEXT_MES_REPLACE_AND_DELETE_DUBLICATES = 'Заменить и удалить дубликаты';
 TEXT_MES_SKIP = 'Пропустить';
 TEXT_MES_SKIP_FOR_ALL = 'Пропустить все';
 TEXT_MES_REPLACE = 'Заменить';
 TEXT_MES_REPLACE_FOR_ALL = 'Заменить все';
 TEXT_MES_ADD = 'Добавить';
 TEXT_MES_ADD_FOR_ALL = 'Добавить все';
 TEXT_MES_DELETE_FILE = 'Удалить файл';
 TEXT_MES_DELETE_FILE_CONFIRM = 'Вы действительно хотите удалить этот файл?';

 TEXT_MES_DB_FILE_INFO = 'Текущая информация по БД';
 TEXT_MES_RECREATING_TH_TABLE = 'База';
 TEXT_MES_BEGIN_RECREATING_TH_TABLE = 'Начало обновления таблицы. Это долгое действие, пожалуйста - подождите... (чтобы прервать действие, нажмите Ctrl+B)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT = 'Обновление записи %s из %s [%s]';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_POSTPONED = 'Обновлениииие записи %s из %s [%s] отложено (зашифроваана)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CD_DVD_CANCELED_INFO_F = 'Обновление записи %s из %s [%s] отменено (CD\DVD файлы обновляются из окна управлениями дисками)';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_FIXED = 'Для записи %s из %s [%s] удалён предпросмотр (файл зашифрован, а запись - нет)';
 TEXT_MES_RECREATING = 'Обновление...';
 TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_ERROR = 'Ошибка обновления записи %s';
 TEXT_MES_RECREATINH_TH_FORMAT_ERROR = 'Ошибка обновления записей';
 TEXT_MES_BREAK_RECREATING_TH = 'Вы действительно хотите отменить текущее действие?';
 TEXT_MES_ENTER_NAME_ERROR = 'Введите, пожалуйста, ваше имя';
 TEXT_MES_UPDATING_DESCTIPTION = 'Обновление БД';
 TEXT_MES_DB_EXISTS__USE_NEW = 'Конечная БД уже существует! Вы действительно хотите использовать новую таблицу "%s" (или добавить её)?'#13'YES - добавить записи'#13'NO - использовать новую таблицу (Старая будет УДАЛЕНА!)'#13'ABORT - не выполнять действий';
 TEXT_MES_SLIDE_SHOW_STEPS_OPTIONS = 'Количество шагов для Слайд-Шоу - %s';
 TEXT_MES_SLIDE_SHOW_GRAYSCALE_OPTIONS = 'Скорость для перехода в чёрно-белый цвет (загрузка) - %s.';
 TEXT_MES_USE_COOL_STRETCH = 'Использовать качественную прорисовку';
 TEXT_MES_SET_AS_DESKTOP_WALLPAPER = 'Сделать рисунком рабочего стола';
 TEXT_MES_SLIDE_SHOW_SLIDE_DELAY = 'Задержка между кадрами (%s)';
 TEXT_MES_USE_EXTERNAL_VIEWER = 'Использовать другой просмотрщик';

 TEXT_MES_EXT_IN_USE = 'Текущие расширения:';
 TEXT_MES_HOME_PAGE = 'Сайт программы';
 TEXT_MES_GET_CODE = 'Получить код';

 TEXT_MES_EXPORT_CRYPTED_IF_PASSWORD_EXISTS = 'Экспортировать зашифрованные, если найден пароль';
 TEXT_MES_EXPORT_CRYPTED = 'Экспортировать зашифрованные записи';
 TEXT_MES_CANNOT_CREATE_FILE_F = 'Невозможно создать файл "%s"';

 TEXT_MES_SECURITY_INFO = 'ВНИМАНИЕ: это опция всё ещё экспериментальная, используйте осторожно. Если Вы забыли пароль к каким-либо изображениям, их восстановить уже не удастся!';
 TEXT_MES_SECURITY_USE_SAVE_IN_SESSION = 'Автоматически сохранять пароли для текущей сессии';
 TEXT_MES_SECURITY_USE_SAVE_IN_INI = 'Автоматически сохранять пароли в настройках (НЕ РЕКОМЕНДУЕТСЯ)';
 TEXT_MES_SECURITY_CLEAR_SESSION = 'Очистить текущие пароли в сессии';
 TEXT_MES_SECURITY_CLEAR_INI = 'Очистить текущие пароли в настройках';
 TEXT_MES_SECURITY = 'Безопасность';

 TEXT_MES_SHOW_DUBLICATES = 'Показать дубликаты';
 TEXT_MES_DUBLICATES = 'Дубликаты';
 TEXT_MES_DEL_DUBLICATES  = 'Удалить другие дубликаты';

 TEXT_MES_UNABLE_SHOW_FILE_F = 'Невозможно отобразить файл:'#13'%s';
 TEXT_MES_DIRECT_X_FAILTURE = 'Ошибка инициализации графического режима';
 TEXT_MES_NEW_UPDATING_CAPTION = 'Доступна новая версия - %s';
 TEXT_MES_DOWNLOAD_NOW = 'Загрузить сейчас!';
 TEXT_MES_REMAIND_ME_LATER = 'Напомнить мне потом';
 TEXT_MES_NEW_COMMAND = 'Новый пункт меню';
 TEXT_MES_USER_MENU = 'Меню';
 TEXT_MES_USER_SUBMENU = 'Дополнительно';
 TEXT_MES_USER_MENU_ITEM = 'Пункт меню';
 TEXT_MES_CAPTION = 'Заголовок';
 TEXT_MES_EXECUTABLE_FILE = 'Исполняемый файл';
 TEXT_MES_EXECUTABLE_FILE_PARAMS = 'Параметры запуска';
 TEXT_MES_ICON = 'Иконка';
 TEXT_MES_USE_SUBMENU = 'Добавить в субменю';

 TEXT_MES_USER_SUBMENU_ICON = 'Иконка субменю';
 TEXT_MES_USER_SUBMENU_CAPTION = 'Заголовок субменю';
 TEXT_MES_USE_USER_MENU_FOR_ID_MENU = 'ID Меню';
 TEXT_MES_USE_USER_MENU_FOR_VIEWER = 'Просмотра';
 TEXT_MES_USE_USER_MENU_FOR_EXPLORER = 'Проводника';
 TEXT_MES_USE_USER_MENU_FOR = 'Использовать меню для:';
 TEXT_MES_REMOVE_USER_MENU_ITEM = 'Удалить';
 TEXT_MES_ADD_NEW_USER_MENU_ITEM = 'Добавить новый пункт';

 TEXT_MES_NEEDS_INTERNET_CONNECTION = 'Невозможно получить информацию об обновлениях т.к. не обнаружено соединения с интернетом';
 TEXT_MES_CANNOT_FIND_SITE = 'Не удалось получить информацию об обновлениях';
 TEXT_MES_NO_UPDATES = 'Не обнаружено новых версий программы';
 TEXT_MES_ITEM_DOWN = 'Вниз';
 TEXT_MES_ITEM_UP = 'Вверх';
 TEXT_MES_DO_SLIDE_SHOW = 'Слайд-Шоу';
 TEXT_MES_BEGIN_NO = 'Начать с:';
 TEXT_MES_NEXT_HELP = 'Далее...';
 TEXT_MES_HELP_FIRST = '     Для добавления фотографий в Базу Данных (БД) выберите пункт "Проводник" в контекстном меню, затем найдите ваши фотографии и в меню выберите "добавить объекты".'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13#13;
 TEXT_MES_CLOSE_HELP = 'Вы действительно хотите отказаться от помощи?';
 TEXT_MES_HELP_1 = '     Найдите в проводнике папку с вашими фотографиями и, выделив фотографии, в меню выберите "Добавить объект(ы)".'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_2 = '     Нажмите на кнопку "Добавить объект(ы)" чтобы добавить фотографии в БД. После этого к фотографии можно добавлять информацию.'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_3 = '     Теперь фотографии, у которых не отображается иконка (+) в верхнем левом углу находятся в БД. Они доступны по поиску в окне поиска и к ним доступно контекстное меню со свойствами. Дальнейшая справка доступна из главного меню (Справка -> Справка).'#13' '#13;

 TEXT_MES_SLIDE_SHOW_SPEED = 'Дополнительная задержка для Слайд-Шоу - %s ms.';
 TEXT_MES_FULL_SCREEN_SLIDE_SPEED = 'Скорость слайдов для полноэкранного режима - %s ms.';

 TEXT_MES_CLEAR_FOLDER_IMAGES_CASH = 'Очистить кэш предпросмотров';
 TEXT_MES_CLEAR_ICON_CASH = 'Очистить кэш иконок';
 TEXT_MES_HELP_ACTIVATION_FIRST = '     Вы хотите получить справку, как активировать программу? Если ДА, то нажмите на кнопку "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_ACTIVATION_1 = '     Для активации программы в контекстном меню выберите пункт "Справка"->"Активация программы"'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;

 TEXT_MES_HELP_ACTIVATION_2 = '     Для активации программы в контекстном меню выберите пункт "Справка"->"Активация программы"'#13#13'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13;
 TEXT_MES_HELP_ACTIVATION_3 = '     Нажмите на кнопку "'+TEXT_MES_GET_CODE+'", после чего запустится почтовая программа с новым письмом, в заголовке которого дана вся необходимая  для активации информация.'#13'вам необходимо отослать это письмо или же (если почтовая программа не запустилась)'+
 ' самим отправить письмо на адрес '+ProgramMail+', в котором нужно указать код программы и её версию.'#13#13+'     Нажмите "'+TEXT_MES_NEXT_HELP+'" для дальнейшей помощи.'#13'     Или нажмите на крестик сверху, чтобы справка более не отображалась.'#13' '#13#13' '#13;
 TEXT_MES_HELP_ACTIVATION_4 = '     В течении суток вам будет ввыслан код активации, который нужно ввести в это окно и нажать на кнопку "'+TEXT_MES_SET_CODE+'". После этого программа будет активирована.'#13' '#13;

 TEXT_MES_WAIT_ACTION = 'Пожалуйста, подождите, пока программа выполнит текущую операцию и обновит базу данных.';
 TEXT_MES_SET = 'Установить';

 TEXT_MES_OPEN_FILE = 'Открыть файл';

 TEXT_MES_APPLICATION_NOT_VALID = 'Приложение повреждено! Возможно, что оно инфицировано каким-либо вирусом!';
 TEXT_MES_FULL_SCREEN = 'На весь экран';

 TEXT_MES_OTHER_PLACES = 'Другие места';
 TEXT_MES_MY_PICTURES = 'Мои картинки';
 TEXT_MES_MY_DOCUMENTS = 'Мои документы';
 TEXT_MES_DESKTOP = 'Рабочий стол';

 TEXT_MES_EXPORT = 'Экспорт';

 TEXT_MES_SHOW_EXIF_MARKER = 'Показывать EXIF заголовок';

 TEXT_MES_USE_SCANNING_BY_FILENAME = 'Использовать узнавание при совпадении имени';
 TEXT_MES_SHOW_OTHER_PLACES = 'Отображать ссылки "Другие места"';

 TEXT_MES_PROGRESS_FORM = 'Выполняется действие';
 TEXT_MES_LOAD_IMAGE = 'Загрузить изображение';
 TEXT_MES_NEXT_ON_CLICK = '"Следующий" при клике';

 TEXT_MES_USE_HOT_SELECT_IN_LISTVIEWS = 'Использовать выделение при наведении в списках';
 TEXT_MES_GLOBAL = 'Глобальные';
 TEXT_MES_ROTATE_WITHOUT_PROMT = 'Поворачивать изображение на диске не спрашивая подтверждения';
 TEXT_MES_ROTATE_EVEN_IF_FILE_IN_DB = 'Даже если файл в БД, поворачивать на диске';

 TEXT_MES_VAR_VALUES = 'Различные значения';
 TEXT_MES_DIRECTORY_NOT_EXISTS_F = 'Директория "%s" не найдена';
 TEXT_MES_SORT_GROUPS = 'Сортировать группы';

 TEXT_MES_USE_GDI_PLUS = 'Использовать GDI+';
 TEXT_MES_GDI_PLUS_DISABLED_INFO = 'GDI+ недоступно, обратитесь к справке для решения проблемы';
 TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED = 'Файл базы данных имеет атрибут "Только чтение"! Снимите атрибут и попробуйте снова';
 TEXT_MES_OPEN_ACTIVATION_FORM = 'Открыть форму активации';

//v2.0

 TEXT_MES_FIX_DATE_AND_TIME = 'Считывать дату с EXIF';

 TEXT_MES_CREATE_BACK_UP_EVERY = 'Создавать резервную копию каждые:';
 TEXT_MES_DAYS = 'дней';
 TEXT_MES_MANY_INSTANCES_OF_PROEPRTY = 'Разрешить загрузку нескольких копий окна свойств';
 TEXT_MES_AND_OTHERS = ' и другие...';
 TEXT_MES_ERROR_EXESQSL_BY_REASON_F = 'Ошибка при выполнении запроса:'#13'%s'#13'%s';
 TEXT_MES_GO_TO_CURRENT_TIME = 'Перейти к текущему времени';
 TEXT_MES_SEL_NEW_PLACE = 'Выберите папку';
 TEXT_MES_NEW_PLACE = 'Новое место';
 TEXT_MES_SHOW_PLACE_IN = 'Отображать в:';
 TEXT_MES_USER_DEFINED_PLACES = 'Дополнительные места:';
 TEXT_MES_PLACES = 'Места:';
 TEXT_MES_ACTION_BREAKED_ITEM_FORMAT = 'Действие было прервано на записи %s из %s [%s]';
 TEXT_MES_DELETE_DB_BACK_UP_CONFIRM_F = 'Вы действительно хотите удалить эту копию БД ("%s")?';
 TEXT_MES_RESTORING_TABLE = 'Восстановление БД:';
 TEXT_MES_BEGIN_RESTORING_TABLE = 'Начало обновления таблицы. Пожалуйста - подождите...';
 TEXT_MES_RESTORING = 'Восстановление';
 TEXT_MES_ERROR_CREATE_BACK_UP_DEFAULT_DB = 'Ошибка! Не удалось сделать резервную копию текущей БД!';
 TEXT_MES_ERROR_COPYING_DB = 'Не удалось восстановить БД (%s)! Текущая БД может быть повреждена или отсутствовать! После запуска попробуйте восстановить файл "%s" в котором находится резервная копия вашей БД';

 TEXT_MES_CONTENTS = 'Содержание';
 TEXT_MES_OPEN_TABLE_ERROR_F = 'Ошибка открытия таблицы "%s"';
 TEXT_MES_UNKNOWN = 'Неизвестно';
 TEXT_MES_CRYPT_FILE_WITHOUT_PASS_MOT_ADDED = 'Не удалось добавить в БД один или несколько файлов. Для уточнения выберите "История" в контекстном меню'#13#13;
 TEXT_MES_FIXED_TH_FOR_ITEM = 'Обновлена информация у файла "%s"';
 TEXT_MES_FAILED_TH_FOR_ITEM = 'Не удалось получить информацию у файла "%s" по причине: %s';
 TEXT_MES_CURRENT_ITEM_F = 'Текущая запись %s из %s [%s]';
 TEXT_MES_CURRENT_ITEM_LINK_BAD = 'Неверная ссылка в записи #%d [%s]. Ссылка "%s" типа "%s"';
 TEXT_MES_BAD_LINKS_TABLE = 'Будет произведён поиск недействительных ссылок по БД:';
 TEXT_MES_BAD_LINKS_TABLE_WORKING = 'Выполняется поиск,  пожалуйста, подождите... '#13'(по завершению лог будет скопирован в буфер обмена)';
 TEXT_MES_BAD_LINKS_TABLE_WORKING_1 = 'Выполняется поиск';
 TEXT_MES_BAD_LINKS_CAPTION = 'Битые ссылки';
 TEXT_MES_RECORDS_ADDED = 'Записей добавлено';
 TEXT_MES_RECORDS_UPDATED = 'Записей обновлено';
 TEXT_MES_ALLOW_VIRTUAL_CURSOR_IN_EDITOR = 'Виртуальный курсор в редакторе';
 TEXT_MES_NEW_W = 'Новая';
 TEXT_MES_SAVE = 'Сохранить';
 TEXT_MES_COPY = 'Скопировать';
 TEXT_MES_STOP = 'Стоп';
 TEXT_MES_ERROR = 'Ошибка';

 TEXT_MES_BACK_UP_TABLE = 'Создание резервной копии БД';
 TEXT_MES_BACKUPING = 'Копирование';
 TEXT_MES_DB_BY_DEFAULT = 'БД';

 TEXT_MES_SEL_FOLDER_SPLIT_DB = 'Пожалуйста, выберите папку для размещения части БД';
 TEXT_MES_SPLIT_DB_CAPTION = 'Разбивка БД';
 TEXT_MES_DELETE_RECORDS_AFTER_FINISH = 'Удалить записи по окончанию';
 TEXT_MES_FILES_AND_FOLDERS = 'Файлы и папки:';
 TEXT_MES_SPLIT_DB_INFO = 'Перетащите в список файлы и папки, в которых содержатся изображения, которые необходимо перенести в другую БД';
 TEXT_MES_METHOD = 'Метод';
 TEXT_MES_SELECT_DB_PLEASE = 'Пожалуйста, выберите сперва базу данных';
 TEXT_MES_REALLY_SPLIT_IN_DB_F = 'Вы действительно хотите разбить БД и использовать данный файл:'#13'"%s" ?'#13'ВНИМАНИЕ:'#13'ВО время разбивки другие окна будут недоступны!';
 TEXT_MES_RELOAD_DATA = 'Перезагрузить данные в окнах?';

 TEXT_MES_WAINT_OPENING_QUERY = 'Пожалуйста, подождите пока выполниться запрос';

 TEXT_MES_DO_UPDATE_IMAGES_ON_IMAGE_CHANGES = 'Следить за изменением файлов и обновлять ссылки (замедляет работу - читайте help)';
 TEXT_MES_DB_TYPE = 'Тип БД:';

 TEXT_MES_DEFAULT_DB_NAME = 'MyDB';
 TEXT_MES_SELECT_DB = 'Выбрать БД';
 TEXT_MES_MOVING_DB_INIT = 'Инициализация импорта! Может занять несколько минут';

 TEXT_MES_NO_RECORDS_FOUNDED_TO_SAVE = 'Нет найденных записей для сохранения';
 TEXT_MES_MAKE_FOLDERVIEWER = 'Создать БД-Вьювер';
 TEXT_MES_OPTIMIZANG_DUBLICATES = 'Оптимизация дубликатоов... (Ctrl+B для прекращения)';
 TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING = 'Выполняется сканирование БД, пожалуйста, подождите... ';
 TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING_1 = 'Выполняется сканирование БД';
 TEXT_MES_OPTIMIZING_DUBLICATES = 'Оптимизировать дубликаты';

 TEXT_MES_CURRENT_ITEM_UPDATED_DUBLICATES = 'Обновлена запись #%d [%s]';
 TEXT_MES_DB_VIEW_ABOUT_F = 'Автономная база данных созданная с помощью "%s". В этой программе отключены многие функции, доступные в полной версии.';
 TEXT_MES_SELECT_FOLDER = 'Выберите папку';
 TEXT_MES_RUN_EXPLORER_AT_ATARTUP = 'Запускать проводник при запуске';
 TEXT_MES_USE_SPECIAL_FOLDER = 'Использовать папку';
 TEXT_MES_NO_ADD_SMALL_FILES_WITH_WH = 'Не добавлять в БД файлы, размером меньше:';

 TEXT_MES_UNKNOWN_DB_VERSION = 'Неизвестная версия БД';
 TEXT_MES_DIALOG_CONVERTING_DB = 'Этот диалог поможет вам конвертировать Вашу базу данных из одного формата в другой.';
 TEXT_MES_CONVERT_TO_MDB = 'Конвертировать в *.photodb (PhotoDB)';
 TEXT_MES_CONVERTING_CAPTION = 'Конвертирование БД';
 TEXT_MES_CONVERTING_SECOND_STEP = 'Подождите пока выполнится преобразование БД, это может потребовать несколько минут...';
 TEXT_MES_CONVERTING_IMAGE_SIZES_STEP = 'Вы можете настроить размеры и качество сжатия изображений в БД, а также выбрать размеры по умолчанию окон предпросмотра и контейнера изображений '+'(их можно изменить в дальнейшем без конвертации базы)';
 TEXT_MES_CONVERT_DB = 'Конвертировать БД';
 TEXT_MES_DO_YOU_REALLY_WANT_TO_CLOSE_THIS_DIALOG = 'Вы действительно хотите закрыть этот диалог?';
 TEXT_MES_CONVETRING_ENDED = 'Конвертирование БД завершено!';
 TEXT_MES_FINISH = 'Финиш!';

 TEXT_MES_CREATING_DB = 'Создание базы данных';
 TEXT_MES_CREATING_DB_OK = 'Создание БД успешно завершено';
 TEXT_MES_OPENING_DATABASES = 'Открытие БД';               
 TEXT_MES_CONVERTING_ENDED = 'Конвертирование завершено!';
 TEXT_MES_CONVERTION_IN_PROGRESS = 'Конвертирование структуры...';
 TEXT_MES_UPDATING_SETTINGS_OK = 'Обновление настроек базы завершено!';
 TEXT_MES_IMPORT_IMAGES_CAPTION = 'Импорт ваших изображений в БД';
 TEXT_MES_IMPORTING_IMAGES_INFO = 'Этот диалог поможет вам добавить в БД ваши фотографии или другие изображения';

 TEXT_MES_IMPORTING_IMAGES_FIRST_STEP = 'Выберите папки откуда будут импортировать изображения';
 TEXT_MES_FOLDERS_TO_ADD = 'Папки для импорта';
 TEXT_MES_CURRENT_DB_FILE = 'Текущий файл БД';
 MAKE_MES_NEW_DB_FILE = 'Новый файл БД';
 TEXT_MES_DB_FILE = 'Файл БД';
 TEXT_MES_IMPORTING_IMAGES_SECOND_STEP = 'Выберите дополнителльные опции импорта изображений.';
 TEXT_MES_IMPORTING_IMAGES_THIRD_STEP = 'Нажмите на "'+TEXT_MES_START_NOW+'" и подождите пока программа найдёт и добавит все ваши изображения. Это может потребовать много времени в зависимости от величины вашего фотоальбома.';
 TEXT_MES_AKS_ME = 'Спросить меня';
 TEXT_MES_IF_CONFLICT_IMPORTING_DO = 'При нахождении дубликатов';
 TEXT_MES_CALCULATION_IMAGES = 'Подсчёт изображений...';
 TEXT_MES_CURRENT_SIZE_F = 'Текущий размер - %s';
 TEXT_MES_IMAGES_COUNT_F = 'Найдено фотографий - %d';
 TEXT_MES_PROCESSING_IMAGES = 'Обработка изображений';
 TEXT_MES_PROCESSING_SIZE_F = 'Размер %s из %s';
 TEXT_MES_IMAGES_PROCESSED_COUNT_F = 'Обработано %d из %d';
 TEXT_MES_TIME_REM_F = 'Осталось времени - %s (&%%%%)'; //with progres

 TEXT_MES_RECORDS_FOUNDED = 'Найденные записи';
 TEXT_MES_OTHERS = 'Другое';
 TEXT_MES_BACKUPING_GROUP = 'Резервное копирование';
 TEXT_MES_SHOW_GROUPS_IN_SEARCH = 'Разбивать на группы в поисковике';
 TEXT_MES_PASSWORDS = 'Пароли';

 TEXT_MES_DB_NAME = 'Имя БД';
 TEXT_MES_ENTER_CUSTOM_DB_NAME = 'Введите имя новой БД:';
 TEXT_MES_DO_YOU_WANT_REPLACE_ICON_QUESTION = 'Вы хотите заменить иконку у конечной БД?';

 TEXT_MES_NO_PLACES_TO_IMPORT = 'Не выбрано ни одного пути для добавления - продолжение невозможно. Нажмите на кнопку "'+TEXT_MES_ADD_FOLDER+'" чтобы добавить путь к фотографиям.';
 TEXT_MES_FILES_ALREADY_EXISTS_REPLACE = 'Папка содержит уже файлы с такими именами, заменить их?';
 TEXT_MES_DO_YOU_REALLY_WANT_CANCEL_OPERATION = 'Вы действительно хотите прервать выполнение текущей операции?';

 TEXT_MES_STENO_USE_FILTER_NORMAL = 'Нормальный размер (практически незаметно)';
 TEXT_MES_STENO_USE_FILTER_GOOD = 'Лучший размер (незаметно)';
 TEXT_MES_CONFIRMATION = 'Подтверждение';

 TEXT_MES_CONVERTING_ERROR_F = 'Произошла ошибка во время конвертации базы! (%s)';
 TEXT_MES_UNKNOWN_DB = 'Неизвестная база';

 TEXT_MES_CONVERTATION_JPEG_QUALITY = 'JPEG качество';
 TEXT_MES_CONVERTATION_JPEG_QUALITY_INFO = 'Устанавливает качество сжатия изображения, хранимых в базе. Принимает значение 1-100';
 TEXT_MES_CONVERTATION_TH_SIZE = 'Изображения в БД';
 TEXT_MES_CONVERTATION_TH_SIZE_INFO = 'При загрузке данных используется по умолчанию этот размер';
 TEXT_MES_CONVERTATION_HINT_SIZE = 'Предпросмотр';
 TEXT_MES_CONVERTATION_HINT_SIZE_INFO = 'Размер предпросмотра к изображениям';
 TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE = 'Панель';
 TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE_INFO = 'Размер изображений в панели по умолчанию';

 TEXT_MES_IMAGE_SIZE_FORMAT = 'Размер изображения = %s';
 TEXT_MES_CANNOT_DELETE_FILE_NEW_NAME_F = 'Не удаётся удалить файл %s, возможно он занят другой программой или процессом. Будет использовано другое иимя (имя_файла_1)';
 TEXT_MES_LOAD_DIFFERENT_IMAGE = 'Загрузить другое изображение';

 TEXT_MES_RECREATING_PREVIEWS = 'Обновление предпросмотров в базе...';
 TEXT_MES_BACKUP_SUCCESS = 'Резервное копирование успешно завершено';
 TEXT_MES_PROSESSING_ = 'Выполняется:';
 TEXT_MES_FILES_MERGED = 'Файл объединён';
 TEXT_MES_RECORD_NOT_FOUND_F = 'Запись %d не найдена по ключу -> расширенный поиск';
 TEXT_MES_RECORD_NOT_FOUND_ERROR_F = 'Запись %d не найдена! [%s]';
 TEXT_MES_LOADING_BREAK = 'Загрузка прервана...';
 TEXT_MES_DB_NAME_PATTERN = 'Новая база';
 TEXT_MES_USE_ANOTHER_DB_FILE = 'Использовать другой файл:';
 TEXT_MES_NEW_DB_FILE = '<Новый файл БД>';
 TEXT_MES_ERROR_DB_FILE_F = 'Неверный или несуществующий файл '#13'"%s"!'#13' Проверьтте наличие файла или попробуйте добавить его через менеджер БД - возможно, файл был создан в предыдущей версии программы и необходимо его сконвертировать в текущую версию';
 TEXT_MES_THANGE_FILES_PATH_IN_DB = 'Сменить путь для файлов в базе';

 TEXT_MES_SELECT_DB_CAPTION = 'Диалог выбора\создания\редактирования БД';
 TEXT_MES_SELECT_DB_OPTIONS = 'Выберите нужное действие';
 TEXT_MES_SELECT_DB_OPTION_1 = 'Создание нового файла Базы  Данных';  
 TEXT_MES_SELECT_DB_OPTION_2 = 'Использовать существующий файл на жёстком диске';
 TEXT_MES_SELECT_DB_OPTION_3 = 'Использовать зарегистрированную базу';
 TEXT_MES_SELECT_DB_OPTION_STEP1 = 'Выберите нужное действие из списка и нажмите на кнопку "'+TEXT_MES_NEXT+'"';

 TEXT_MES_DB_NAME_AND_LOCATION = 'Название и месторасположение файлов';
 TEXT_MES_DB_ENTER_NEW_DB_NAME = 'Введите имя для новой базы';
 TEXT_MES_CHOOSE_NEW_DB_PATH = 'Выберите файл для новой базы';
 TEXT_MES_CHOOSE_ICON = 'Выбрать иконку';
 TEXT_MES_SELECT_DB_FILE = 'Выбрать файл';
 TEXT_MES_ICON_PREVIEW = 'Предпросмотр иконки';
 TEXT_MES_SELECT_ICON = 'Выбрать иконку';
 TEXT_MES_NO_DB_FILE_SELECTED = 'Не выбран файл базы данных! Выберите файл и попробуйте снова';
 TEXT_MES_VALUE  = 'Значение';

 TEXT_MES_NEW_DB_WILL_CREATE_WITH_THIS_OPTIONS = 'Новая база будет создана со следующими настройками:'#13#13;
 TEXT_MES_NEW_DB_NAME_FORMAT = 'Имя базы: "%s"';
 TEXT_MES_NEW_DB_PATH_FORMAT = 'Путь к базе: "%s"';  
 TEXT_MES_NEW_DB_ICON_FORMAT = 'Путь к иконке: "%s"';  
 TEXT_MES_NEW_DB_IMAGE_SIZE_FORMAT = 'Размер изображений в базе: %dpx';
 TEXT_MES_NEW_DB_IMAGE_QUALITY_FORMAT = 'Качество изображений: %dpx';
 TEXT_MES_NEW_DB_IMAGE_HINT_FORMAT = 'Предпросмотр : %dpx';
 TEXT_MES_NEW_DB_IMAGE_PANEL_PREVIEW = 'Изображения в панели : %dpx';

 TEXT_MES_SELECT_DB_FROM_LIST = 'Выбрать БД из списка';
 TEXT_MES_SELECT_FILE_ON_HARD_DISK = 'Выберите файл с диска';
 TEXT_MES_CHANGE_DB_OPTIONS = 'Изменить опции БД';
 TEXT_MES_CREATE_EXAMPLE_DB = 'Создать стандартную базу*';
 TEXT_MES_DB_DESCRIPTION = 'Описание базы';
 TEXT_MES_DB_PATH = 'Путь к базе';
 TEXT_MES_OPEN_FILE_LOCATION = 'Открыть месторасположение файла';
 TEXT_MES_CHANGE_FILE_LOCATION = 'Изменить расположение файла';
 TEXT_MES_PRESS_THIS_LINK_TO_CONVERT_DB = 'Для изменения размеров предпросмотров и качества запустите мастер конвертации базы';
 TEXT_MES_DB_CREATED_SUCCESS_F = 'База "%s" успешно создана';
 TEXT_MES_ADD_DEFAULT_GROUPS_TO_DB = 'Добавить стандартные группы';
 TEXT_MES_SHOW_FILE_IN_EXPLORER = 'Показать файл в проводнике';

 TEXT_MES_USE_FULL_RECT_SELECT = 'Использовать полное выделение в списках';
 TEXT_MES_LIST_VIEW_ROUND_RECT_SIZE = 'Размер закруглленния:';
 TEXT_MES_SELECT_DB_AT_FIRST = 'Сперва выберите файл базы данных!';
 TEXT_MES_DB_FILE_NOT_FOUND_ERROR = 'Файл базы не найдён при запуске приложения!'#13'Выберите другой файл или создайте новый.';

 TEXT_MES_ICON_OPTIONS = 'Настройки иконки';
 TEXT_MES_INTERNAL_NAME = 'Отображаемое имя';
 TEXT_MES_USE_SLIDE_SHOW_FAST_LOADING = 'Использовать быструю загрузку файлов (бд в фоне)';
 TEXT_MES_DEFAULT_PROGRESS_TEXT = 'Прогресс... (&%%)';

 TEXT_MES_UNABLE_TO_COPY_DISK = 'Невозможно скопировать файлы в конечное рамещение! Проверьте, имеются ли права записи в указанную директорию!';
 TEXT_MES_UNABLE_TO_DELETE_ORIGINAL_FILES = 'Не удалось удалить оригинальные файлы! Проверьте, имеете ли Вы право на удаление файлов. Попробуйте позже вручную удалить эти файлы.';
 TEXT_MES_USE_SMALL_TOOLBAR_ICONS = 'Ипользовать маленькие иконки для тубларов';

 TEXT_MES_ICONS_OPEN_MASK = 'Все поддерживаемые форматы|*.exe;*.ico;*.dll;*.ocx;*.scr|Иконки (*.ico)|*.ico|Исполняемые файллы (*.exe)|*.exe|Dll файлы (*.dll)|*.dll';

implementation

end.
