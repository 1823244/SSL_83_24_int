﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Обновляет возможные права для настройки прав объектов и сохраняет состав последних изменений.
// 
// Параметры:
//  ЕстьИзменения - Булево (возвращаемое значение) - если изменения найдены,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьВозможныеПраваДляНастройкиПравОбъектов(ЕстьИзменения = Неопределено) Экспорт
	
	ВозможныеПрава = ВозможныеПрава();
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		
		СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВозможныеПраваДляНастройкиПравОбъектов",
			ВозможныеПрава, ЕстьТекущиеИзменения);
		
		СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВозможныеПраваДляНастройкиПравОбъектов",
			?(ЕстьТекущиеИзменения,
			  Новый ФиксированнаяСтруктура("ЕстьИзменения", Истина),
			  Новый ФиксированнаяСтруктура()) );
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЕстьТекущиеИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Процедура обновляет вспомогательные данные регистра по результату изменения
// возможных прав по значениям доступа, сохраненных в параметрах ограничения доступа.
//
Процедура ОбновитьВспомогательныеДанныеРегистраПоИзменениямКонфигурации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПоследниеИзменения = СтандартныеПодсистемыСервер.ИзмененияПараметраРаботыПрограммы(
		"СтандартныеПодсистемы.УправлениеДоступом.ВозможныеПраваДляНастройкиПравОбъектов");
		
	Если ПоследниеИзменения = Неопределено Тогда
		ТребуетсяОбновление = Истина;
	Иначе
		ТребуетсяОбновление = Ложь;
		Для каждого ЧастьИзменений Из ПоследниеИзменения Цикл
			
			Если ТипЗнч(ЧастьИзменений) = Тип("ФиксированнаяСтруктура")
			   И ЧастьИзменений.Свойство("ЕстьИзменения")
			   И ТипЗнч(ЧастьИзменений.ЕстьИзменения) = Тип("Булево") Тогда
				
				Если ЧастьИзменений.ЕстьИзменения Тогда
					ТребуетсяОбновление = Истина;
					Прервать;
				КонецЕсли;
			Иначе
				ТребуетсяОбновление = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ТребуетсяОбновление Тогда
		ОбновитьВспомогательныеДанныеРегистра();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает настройки прав объекта.
//
// Параметры:
//  СсылкаНаОбъект - ссылка на объект для которого нужно прочитать настройки прав.
//
// Возвращаемое значение:
//  Структура
//    Наследовать        - Булево - флажок наследования настроек прав родителей.
//    Настройки          - ТаблицаЗначений
//                         - ВладелецНастройки     - ссылка на объект или родителя объекта
//                                                   (из иерархии родителей объекта).
//                         - НаследованиеРазрешено - Булево - разрешено наследование.
//                         - Пользователь          - СправочникСсылка.Пользователи
//                                                   СправочникСсылка.ГруппыПользователей
//                                                   СправочникСсылка.ВнешниеПользователи
//                                                   СправочникСсылка.ГруппыВнешнихПользователей.
//                         - <ИмяПрава1>           - Неопределено, Булево
//                                                       Неопределено - право не настроено,
//                                                       Истина       - право разрешено,
//                                                       Ложь         - право запрещено.
//                         - <ИмяПрава2>           - ...
//
Функция Прочитать(Знач СсылкаНаОбъект) Экспорт
	
	ВозможныеПрава = УправлениеДоступомСлужебныйПовтИсп.ВозможныеПраваДляНастройкиПравОбъектов();
	
	ОписаниеПрав = ВозможныеПрава.ПоТипам.Получить(ТипЗнч(СсылкаНаОбъект));
	
	Если ОписаниеПрав = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка в процедуре РегистрыСведений.НастройкиПравОбъектов.Прочитать()
			           |
			           |Неверное значение параметра СсылкаНаОбъект ""%1"".
			           |Для объектов таблицы ""%2"" права не настраиваются.'"),
			Строка(СсылкаНаОбъект),
			СсылкаНаОбъект.Метаданные().ПолноеИмя());
	КонецЕсли;
	
	НастройкиПрав = Новый Структура;
	
	// Получения значения настройки наследования.
	НастройкиПрав.Вставить("Наследовать",
		РегистрыСведений.НаследованиеНастроекПравОбъектов.НаследованиеНастроек(СсылкаНаОбъект));
	
	// Подготовка структуры таблицы настроек прав.
	Настройки = Новый ТаблицаЗначений;
	Настройки.Колонки.Добавить("Пользователь");
	Настройки.Колонки.Добавить("ВладелецНастройки");
	Настройки.Колонки.Добавить("НаследованиеРазрешено", Новый ОписаниеТипов("Булево"));
	Настройки.Колонки.Добавить("НастройкаРодителя",     Новый ОписаниеТипов("Булево"));
	Для каждого ОписаниеПрава Из ОписаниеПрав Цикл
		Настройки.Колонки.Добавить(ОписаниеПрава.Ключ);
	КонецЦикла;
	
	Если ВозможныеПрава.ИерархическиеТаблицы.Получить(ТипЗнч(СсылкаНаОбъект)) = Неопределено Тогда
		НаследованиеНастроек = УправлениеДоступомСлужебныйПовтИсп.ТаблицаПустогоНабораЗаписей(
			Метаданные.РегистрыСведений.НаследованиеНастроекПравОбъектов.ПолноеИмя()).Скопировать();
		НоваяСтрока = НаследованиеНастроек.Добавить();
		НаследованиеНастроек.Колонки.Добавить("Уровень", Новый ОписаниеТипов("Число"));
		НоваяСтрока.Объект   = СсылкаНаОбъект;
		НоваяСтрока.Родитель = СсылкаНаОбъект;
	Иначе
		НаследованиеНастроек = РегистрыСведений.НаследованиеНастроекПравОбъектов.РодителиОбъекта(
			СсылкаНаОбъект, , , Ложь);
	КонецЕсли;
	
	// Чтение настроек объекта и родителей от которых наследуются настройки.
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Объект", СсылкаНаОбъект);
	Запрос.УстановитьПараметр("НаследованиеНастроек", НаследованиеНастроек);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НаследованиеНастроек.Объект,
	|	НаследованиеНастроек.Родитель,
	|	НаследованиеНастроек.Уровень
	|ПОМЕСТИТЬ НаследованиеНастроек
	|ИЗ
	|	&НаследованиеНастроек КАК НаследованиеНастроек
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	НаследованиеНастроек.Объект,
	|	НаследованиеНастроек.Родитель
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НаследованиеНастроек.Родитель КАК ВладелецНастройки,
	|	НастройкиПравОбъектов.Пользователь КАК Пользователь,
	|	НастройкиПравОбъектов.Право КАК Право,
	|	ВЫБОР
	|		КОГДА НаследованиеНастроек.Родитель <> &Объект
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК НастройкаРодителя,
	|	НастройкиПравОбъектов.ПравоЗапрещено КАК ПравоЗапрещено,
	|	НастройкиПравОбъектов.НаследованиеРазрешено КАК НаследованиеРазрешено
	|ИЗ
	|	РегистрСведений.НастройкиПравОбъектов КАК НастройкиПравОбъектов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ НаследованиеНастроек КАК НаследованиеНастроек
	|		ПО НастройкиПравОбъектов.Объект = НаследованиеНастроек.Родитель
	|ГДЕ
	|	НЕ(НаследованиеНастроек.Родитель <> &Объект
	|				И НастройкиПравОбъектов.НаследованиеРазрешено <> ИСТИНА)
	|
	|УПОРЯДОЧИТЬ ПО
	|	НастройкаРодителя УБЫВ,
	|	НаследованиеНастроек.Уровень,
	|	НастройкиПравОбъектов.ПорядокНастройки";
	Таблица = Запрос.Выполнить().Выгрузить();
	
	ТекущийВладелецНастройки = Неопределено;
	ТекущийПользователь = Неопределено;
	Для каждого Строка Из Таблица Цикл
		Если ТекущийВладелецНастройки <> Строка.ВладелецНастройки
		 ИЛИ ТекущийПользователь <> Строка.Пользователь Тогда
			ТекущийВладелецНастройки = Строка.ВладелецНастройки;
			ТекущийПользователь      = Строка.Пользователь;
			Настройка = Настройки.Добавить();
			Настройка.Пользователь      = Строка.Пользователь;
			Настройка.ВладелецНастройки = Строка.ВладелецНастройки;
			Настройка.НастройкаРодителя = Строка.НастройкаРодителя;
		КонецЕсли;
		Если Настройки.Колонки.Найти(Строка.Право) = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка в процедуре РегистрыСведений.НастройкиПравОбъектов.Прочитать()
				           |
				           |Для объектов таблицы ""%1""
				           |право ""%2"" не настраивается, однако оно записано
				           |в регистре сведений НастройкиПравОбъектов для
				           |объекта ""%3"".
				           |
				           |Возможно, обновление информационной базы
				           |не выполнено или выполнено с ошибкой.
				           |Требуется исправить данные регистра.'"),
				СсылкаНаОбъект.Метаданные().ПолноеИмя(),
				Строка.Право,
				Строка(СсылкаНаОбъект));
		КонецЕсли;
		Настройка.НаследованиеРазрешено = Настройка.НаследованиеРазрешено ИЛИ Строка.НаследованиеРазрешено;
		Настройка[Строка.Право] = НЕ Строка.ПравоЗапрещено;
	КонецЦикла;
	
	НастройкиПрав.Вставить("Настройки", Настройки);
	
	Возврат НастройкиПрав;
	
КонецФункции

// Записывает настройки прав объекта.
//
// Параметры:
//  Наследовать - Булево - флажок наследования настроек прав родителей.
//  Настройки   - ТаблицаЗначений со структурой возвращенной функцией Прочитать()
//                записываются только строки, у которых ВладелецНастройки = СсылкаНаОбъект.
//
Процедура Записать(Знач СсылкаНаОбъект, Знач Настройки, Знач Наследовать) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	ВозможныеПрава = УправлениеДоступомСлужебныйПовтИсп.ВозможныеПраваДляНастройкиПравОбъектов();
	ОписаниеПрав = ВозможныеПрава.ПоТипамСсылок.Получить(ТипЗнч(СсылкаНаОбъект));
	
	Если ОписаниеПрав = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка в процедуре РегистрыСведений.НастройкиПравОбъектов.Прочитать()
			           |
			           |Неверное значение параметра СсылкаНаОбъект ""%1"".
			           |Для объектов таблицы ""%2"" права не настраиваются.'"),
			Строка(СсылкаНаОбъект),
			СсылкаНаОбъект.Метаданные().ПолноеИмя());
	КонецЕсли;
	
	// Установка значения настройки наследования.
	НаборЗаписей = РегистрыСведений.НаследованиеНастроекПравОбъектов.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(СсылкаНаОбъект);
	НаборЗаписей.Отбор.Родитель.Установить(СсылкаНаОбъект);
	НаборЗаписей.Прочитать();
	
	Если НаборЗаписей.Количество() = 0 Тогда
		НаследованиеИзменено = Истина;
		НоваяЗапись = НаборЗаписей.Добавить();
		НоваяЗапись.Объект      = СсылкаНаОбъект;
		НоваяЗапись.Родитель    = СсылкаНаОбъект;
		НоваяЗапись.Наследовать = Наследовать;
	Иначе
		НаследованиеИзменено = НаборЗаписей[0].Наследовать <> Наследовать;
		НаборЗаписей[0].Наследовать = Наследовать;
	КонецЕсли;
	
	// Подготовка новых настроек
	НовыеНастройкиПрав = УправлениеДоступомСлужебныйПовтИсп.ТаблицаПустогоНабораЗаписей(
		Метаданные.РегистрыСведений.НастройкиПравОбъектов.ПолноеИмя()).Скопировать();
	
	ТаблицаОбщихПрав = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	
	Отбор = Новый Структура("ВладелецНастройки", СсылкаНаОбъект);
	ПорядокНастройки = 0;
	Для каждого Настройка Из Настройки.НайтиСтроки(Отбор) Цикл
		Для каждого ОписаниеПрава Из ОписаниеПрав Цикл
			Если ТипЗнч(Настройка[ОписаниеПрава.Имя]) <> Тип("Булево") Тогда
				Продолжить;
			КонецЕсли;
			ПорядокНастройки = ПорядокНастройки + 1;
			
			НастройкаПрав = НовыеНастройкиПрав.Добавить();
			НастройкаПрав.ПорядокНастройки      = ПорядокНастройки;
			НастройкаПрав.Объект                = СсылкаНаОбъект;
			НастройкаПрав.Пользователь          = Настройка.Пользователь;
			НастройкаПрав.Право                 = ОписаниеПрава.Имя;
			НастройкаПрав.ПравоЗапрещено        = НЕ Настройка[ОписаниеПрава.Имя];
			НастройкаПрав.НаследованиеРазрешено = Настройка.НаследованиеРазрешено;
			// Кэш-реквизиты
			НастройкаПрав.УровеньРазрешенияПрава =
				?(НастройкаПрав.ПравоЗапрещено, 0, ?(НастройкаПрав.НаследованиеРазрешено, 2, 1));
			НастройкаПрав.УровеньЗапрещенияПрава =
				?(НастройкаПрав.ПравоЗапрещено, ?(НастройкаПрав.НаследованиеРазрешено, 2, 1), 0);
			
			ДобавленыНастройкиОтдельныхТаблиц = Ложь;
			Для каждого КлючИЗначение Из ВозможныеПрава.ОтдельныеТаблицы Цикл
				ОтдельнаяТаблица = КлючИЗначение.Ключ;
				ЧтениеТаблицы    = ОписаниеПрава.ЧтениеВТаблицах.Найти(   ОтдельнаяТаблица) <> Неопределено;
				ИзменениеТаблицы = ОписаниеПрава.ИзменениеВТаблицах.Найти(ОтдельнаяТаблица) <> Неопределено;
				Если НЕ ЧтениеТаблицы И НЕ ИзменениеТаблицы Тогда
					Продолжить;
				КонецЕсли;
				ДобавленыНастройкиОтдельныхТаблиц = Истина;
				НастройкаПравТаблицы = НовыеНастройкиПрав.Добавить();
				ЗаполнитьЗначенияСвойств(НастройкаПравТаблицы, НастройкаПрав);
				НастройкаПравТаблицы.Таблица = ОтдельнаяТаблица;
				Если ЧтениеТаблицы Тогда
					НастройкаПравТаблицы.УровеньРазрешенияЧтения = НастройкаПрав.УровеньРазрешенияПрава;
					НастройкаПравТаблицы.УровеньЗапрещенияЧтения = НастройкаПрав.УровеньЗапрещенияПрава;
				КонецЕсли;
				Если ИзменениеТаблицы Тогда
					НастройкаПравТаблицы.УровеньРазрешенияИзменения = НастройкаПрав.УровеньРазрешенияПрава;
					НастройкаПравТаблицы.УровеньЗапрещенияИзменения = НастройкаПрав.УровеньЗапрещенияПрава;
				КонецЕсли;
			КонецЦикла;
			
			ОбщееЧтение    = ОписаниеПрава.ЧтениеВТаблицах.Найти(   ТаблицаОбщихПрав) <> Неопределено;
			ОбщееИзменение = ОписаниеПрава.ИзменениеВТаблицах.Найти(ТаблицаОбщихПрав) <> Неопределено;
			
			Если НЕ ОбщееЧтение И НЕ ОбщееИзменение И ДобавленыНастройкиОтдельныхТаблиц Тогда
				НовыеНастройкиПрав.Удалить(НастройкаПрав);
			Иначе
				Если ОбщееЧтение Тогда
					НастройкаПрав.УровеньРазрешенияЧтения = НастройкаПрав.УровеньРазрешенияПрава;
					НастройкаПрав.УровеньЗапрещенияЧтения = НастройкаПрав.УровеньЗапрещенияПрава;
				КонецЕсли;
				Если ОбщееИзменение Тогда
					НастройкаПрав.УровеньРазрешенияИзменения = НастройкаПрав.УровеньРазрешенияПрава;
					НастройкаПрав.УровеньЗапрещенияИзменения = НастройкаПрав.УровеньЗапрещенияПрава;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	// Запись настроек прав объекта и значения наследования настроек прав.
	НачатьТранзакцию();
	Попытка
		Данные = Новый Структура;
		Данные.Вставить("НаборЗаписей",   РегистрыСведений.НастройкиПравОбъектов);
		Данные.Вставить("НовыеЗаписи",    НовыеНастройкиПрав);
		Данные.Вставить("ПолеОтбора",     "Объект");
		Данные.Вставить("ЗначениеОтбора", СсылкаНаОбъект);
		
		ЕстьИзменения = Ложь;
		УправлениеДоступомСлужебный.ОбновитьНаборЗаписей(Данные, ЕстьИзменения);
		
		Если ЕстьИзменения Тогда
			ОбъектыСИзменениями = Новый Массив;
		Иначе
			ОбъектыСИзменениями = Неопределено;
		КонецЕсли;
		
		Если НаследованиеИзменено Тогда
			СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
			НаборЗаписей.Записать();
			РегистрыСведений.НаследованиеНастроекПравОбъектов.ОбновитьРодителейВладельца(
				СсылкаНаОбъект, , Истина, ОбъектыСИзменениями);
		КонецЕсли;
		
		Если ОбъектыСИзменениями <> Неопределено Тогда
			ДобавитьОбъектыИерархии(СсылкаНаОбъект, ОбъектыСИзменениями);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Процедура обновляет вспомогательные данные регистра при изменении конфигурации.
// 
// Параметры:
//  ЕстьИзменения - Булево (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьВспомогательныеДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	
	УстановитьПривилегированныйРежим(Истина);
	
	ВозможныеПрава = УправлениеДоступомСлужебныйПовтИсп.ВозможныеПраваДляНастройкиПравОбъектов();
	
	ТаблицыПрав = Новый ТаблицаЗначений;
	ТаблицыПрав.Колонки.Добавить("ВладелецПрав", Метаданные.РегистрыСведений.НастройкиПравОбъектов.Измерения.Объект.Тип);
	ТаблицыПрав.Колонки.Добавить("Право",        Метаданные.РегистрыСведений.НастройкиПравОбъектов.Измерения.Право.Тип);
	ТаблицыПрав.Колонки.Добавить("Таблица",      Метаданные.РегистрыСведений.НастройкиПравОбъектов.Измерения.Таблица.Тип);
	ТаблицыПрав.Колонки.Добавить("Чтение",       Новый ОписаниеТипов("Булево"));
	ТаблицыПрав.Колонки.Добавить("Изменение",    Новый ОписаниеТипов("Булево"));
	
	ПустыеСсылкиВладелецПрав = УправлениеДоступомСлужебныйПовтИсп.СоответствиеПустыхСсылокУказаннымТипамСсылок(
		"РегистрСведений.НастройкиПравОбъектов.Измерение.Объект");
	
	Отбор = Новый Структура;
	Для каждого КлючИЗначение Из ВозможныеПрава.ПоТипамСсылок Цикл
		ТипВладельцаПрав = КлючИЗначение.Ключ;
		ОписаниеПрав     = КлючИЗначение.Значение;
		
		Если ПустыеСсылкиВладелецПрав.Получить(ТипВладельцаПрав) = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка в процедуре ОбновитьВспомогательныеДанныеРегистра
				           |модуля менеджера регистра сведений НастройкиПравОбъектов.
				           |
				           |Тип владельцев прав ""%1"" не указан в измерении Объект.'"),
				ТипВладельцаПрав);
		КонецЕсли;
		
		Отбор.Вставить("ВладелецПрав", ПустыеСсылкиВладелецПрав.Получить(ТипВладельцаПрав));
		Для каждого ОписаниеПрава Из ОписаниеПрав Цикл
			Отбор.Вставить("Право", ОписаниеПрава.Имя);
			
			Для каждого Таблица Из ОписаниеПрава.ЧтениеВТаблицах Цикл
				Строка = ТаблицыПрав.Добавить();
				ЗаполнитьЗначенияСвойств(Строка, Отбор);
				Строка.Таблица = Таблица;
				Строка.Чтение = Истина;
			КонецЦикла;
			
			Для каждого Таблица Из ОписаниеПрава.ИзменениеВТаблицах Цикл
				Отбор.Вставить("Таблица", Таблица);
				Строки = ТаблицыПрав.НайтиСтроки(Отбор);
				Если Строки.Количество() = 0 Тогда
					Строка = ТаблицыПрав.Добавить();
					ЗаполнитьЗначенияСвойств(Строка, Отбор);
				Иначе
					Строка = Строки[0];
				КонецЕсли;
				Строка.Изменение = Истина;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	ТекстЗапросовВременныхТаблиц =
	"ВЫБРАТЬ
	|	ТаблицыПрав.ВладелецПрав,
	|	ТаблицыПрав.Право,
	|	ТаблицыПрав.Таблица,
	|	ТаблицыПрав.Чтение,
	|	ТаблицыПрав.Изменение
	|ПОМЕСТИТЬ ТаблицыПрав
	|ИЗ
	|	&ТаблицыПрав КАК ТаблицыПрав
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиПрав.Объект КАК Объект,
	|	НастройкиПрав.Пользователь КАК Пользователь,
	|	НастройкиПрав.Право КАК Право,
	|	МАКСИМУМ(НастройкиПрав.ПравоЗапрещено) КАК ПравоЗапрещено,
	|	МАКСИМУМ(НастройкиПрав.НаследованиеРазрешено) КАК НаследованиеРазрешено,
	|	МАКСИМУМ(НастройкиПрав.ПорядокНастройки) КАК ПорядокНастройки
	|ПОМЕСТИТЬ НастройкиПрав
	|ИЗ
	|	РегистрСведений.НастройкиПравОбъектов КАК НастройкиПрав
	|
	|СГРУППИРОВАТЬ ПО
	|	НастройкиПрав.Объект,
	|	НастройкиПрав.Пользователь,
	|	НастройкиПрав.Право
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиПрав.Объект,
	|	НастройкиПрав.Пользователь,
	|	НастройкиПрав.Право,
	|	ЕСТЬNULL(ТаблицыПрав.Таблица, ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)) КАК Таблица,
	|	НастройкиПрав.ПравоЗапрещено,
	|	НастройкиПрав.НаследованиеРазрешено,
	|	НастройкиПрав.ПорядокНастройки,
	|	ВЫБОР
	|		КОГДА НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньРазрешенияПрава,
	|	ВЫБОР
	|		КОГДА НЕ НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньЗапрещенияПрава,
	|	ВЫБОР
	|		КОГДА НЕ ЕСТЬNULL(ТаблицыПрав.Чтение, ЛОЖЬ)
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньРазрешенияЧтения,
	|	ВЫБОР
	|		КОГДА НЕ ЕСТЬNULL(ТаблицыПрав.Чтение, ЛОЖЬ)
	|			ТОГДА 0
	|		КОГДА НЕ НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньЗапрещенияЧтения,
	|	ВЫБОР
	|		КОГДА НЕ ЕСТЬNULL(ТаблицыПрав.Изменение, ЛОЖЬ)
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньРазрешенияИзменения,
	|	ВЫБОР
	|		КОГДА НЕ ЕСТЬNULL(ТаблицыПрав.Изменение, ЛОЖЬ)
	|			ТОГДА 0
	|		КОГДА НЕ НастройкиПрав.ПравоЗапрещено
	|			ТОГДА 0
	|		КОГДА НастройкиПрав.НаследованиеРазрешено
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК УровеньЗапрещенияИзменения
	|ПОМЕСТИТЬ НовыеДанные
	|ИЗ
	|	НастройкиПрав КАК НастройкиПрав
	|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицыПрав КАК ТаблицыПрав
	|		ПО (ТИПЗНАЧЕНИЯ(НастройкиПрав.Объект) = ТИПЗНАЧЕНИЯ(ТаблицыПрав.ВладелецПрав))
	|			И НастройкиПрав.Право = ТаблицыПрав.Право
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ТаблицыПрав
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ НастройкиПрав";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НовыеДанные.Объект,
	|	НовыеДанные.Пользователь,
	|	НовыеДанные.Право,
	|	НовыеДанные.Таблица,
	|	НовыеДанные.ПравоЗапрещено,
	|	НовыеДанные.НаследованиеРазрешено,
	|	НовыеДанные.ПорядокНастройки,
	|	НовыеДанные.УровеньРазрешенияПрава,
	|	НовыеДанные.УровеньЗапрещенияПрава,
	|	НовыеДанные.УровеньРазрешенияЧтения,
	|	НовыеДанные.УровеньЗапрещенияЧтения,
	|	НовыеДанные.УровеньРазрешенияИзменения,
	|	НовыеДанные.УровеньЗапрещенияИзменения,
	|	&ПодстановкаПоляВидИзмененияСтроки
	|ИЗ
	|	НовыеДанные КАК НовыеДанные";
	
	// Подготовка выбираемых полей с необязательным отбором.
	Поля = Новый Массив;
	Поля.Добавить(Новый Структура("Объект"));
	Поля.Добавить(Новый Структура("Пользователь"));
	Поля.Добавить(Новый Структура("Право"));
	Поля.Добавить(Новый Структура("Таблица"));
	Поля.Добавить(Новый Структура("ПравоЗапрещено"));
	Поля.Добавить(Новый Структура("НаследованиеРазрешено"));
	Поля.Добавить(Новый Структура("ПорядокНастройки"));
	Поля.Добавить(Новый Структура("УровеньРазрешенияПрава"));
	Поля.Добавить(Новый Структура("УровеньЗапрещенияПрава"));
	Поля.Добавить(Новый Структура("УровеньРазрешенияЧтения"));
	Поля.Добавить(Новый Структура("УровеньЗапрещенияЧтения"));
	Поля.Добавить(Новый Структура("УровеньРазрешенияИзменения"));
	Поля.Добавить(Новый Структура("УровеньЗапрещенияИзменения"));
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТаблицыПрав", ТаблицыПрав);
	
	Запрос.Текст = УправлениеДоступомСлужебный.ТекстЗапросаВыбораИзменений(
		ТекстЗапроса, Поля, "РегистрСведений.НастройкиПравОбъектов", ТекстЗапросовВременныхТаблиц);
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.НастройкиПравОбъектов");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		Данные = Новый Структура;
		Данные.Вставить("МенеджерРегистра",      РегистрыСведений.НастройкиПравОбъектов);
		Данные.Вставить("ИзмененияСоставаСтрок", Запрос.Выполнить().Выгрузить());
		
		УправлениеДоступомСлужебный.ОбновитьРегистрСведений(Данные, ЕстьИзменения);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// См. РегистрыСведений.НастройкиПравОбъектов.ВозможныеПрава.
Функция ВозможныеПраваДляНастройкиПравОбъектов() Экспорт
	
	ВозможныеПрава = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(
		"СтандартныеПодсистемы.УправлениеДоступом.ВозможныеПраваДляНастройкиПравОбъектов");
	
	Если ВозможныеПрава = Неопределено Тогда
		ОбновитьВозможныеПраваДляНастройкиПравОбъектов();
	КонецЕсли;
	
	ВозможныеПрава = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(
		"СтандартныеПодсистемы.УправлениеДоступом.ВозможныеПраваДляНастройкиПравОбъектов");
	
	Возврат ВозможныеПрава;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

Процедура ДобавитьОбъектыИерархии(Ссылка, МассивОбъектов)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	
	Запрос.Текст = СтрЗаменить(
	"ВЫБРАТЬ
	|	ТаблицаСИерархией.Ссылка
	|ИЗ
	|	ТаблицаОбъектов КАК ТаблицаСИерархией
	|ГДЕ
	|	ТаблицаСИерархией.Ссылка В ИЕРАРХИИ(&Ссылка)
	|	И НЕ ТаблицаСИерархией.Ссылка В (&МассивОбъектов)",
	"ТаблицаОбъектов",
	Ссылка.Метаданные().ПолноеИмя());
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		МассивОбъектов.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииВозможныхПравДляНастройкиПравОбъектов.
Функция ВозможныеПрава()
	
	ВозможныеПрава = Новый ТаблицаЗначений();
	ВозможныеПрава.Колонки.Добавить("ВладелецПрав",        Новый ОписаниеТипов("Строка"));
	ВозможныеПрава.Колонки.Добавить("Имя",                 Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(60)));
	ВозможныеПрава.Колонки.Добавить("Заголовок",           Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(60)));
	ВозможныеПрава.Колонки.Добавить("Подсказка",           Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(150)));
	ВозможныеПрава.Колонки.Добавить("НачальноеЗначение",   Новый ОписаниеТипов("Булево,Число"));
	ВозможныеПрава.Колонки.Добавить("ТребуемыеПрава",      Новый ОписаниеТипов("Массив"));
	ВозможныеПрава.Колонки.Добавить("ЧтениеВТаблицах",     Новый ОписаниеТипов("Массив"));
	ВозможныеПрава.Колонки.Добавить("ИзменениеВТаблицах",  Новый ОписаниеТипов("Массив"));
	
	ИнтеграцияСтандартныхПодсистем.ПриЗаполненииВозможныхПравДляНастройкиПравОбъектов(ВозможныеПрава);
	УправлениеДоступомПереопределяемый.ПриЗаполненииВозможныхПравДляНастройкиПравОбъектов(ВозможныеПрава);
	
	ЗаголовокОшибки =
		НСтр("ru = 'Ошибка в процедуре ПриЗаполненииВозможныхПравДляНастройкиПравОбъектов
		           |общего модуля УправлениеДоступомПереопределяемый.'")
		+ Символы.ПС
		+ Символы.ПС;
	
	ПоТипам              = Новый Соответствие;
	ПоТипамСсылок        = Новый Соответствие;
	ПоПолнымИменам       = Новый Соответствие;
	ТипыВладельцев       = Новый Массив;
	ОтдельныеТаблицы     = Новый Соответствие;
	ИерархическиеТаблицы = Новый Соответствие;
	
	ОпределяемыйТипВладельцевПрав  = УправлениеДоступомСлужебныйПовтИсп.ТипыПоляТаблицы("ОпределяемыйТип.ВладелецНастроекПрав");
	ОпределяемыйТипЗначенийДоступа = УправлениеДоступомСлужебныйПовтИсп.ТипыПоляТаблицы("ОпределяемыйТип.ЗначениеДоступа");
	
	СвойстваВидовДоступа = УправлениеДоступомСлужебныйПовтИсп.СвойстваВидовДоступа();
	
	ТипыПодпискиОбновитьГруппыВладельцевНастроекПрав = УправлениеДоступомСлужебныйПовтИсп.ТипыПоляТаблицы(
		"ОпределяемыйТип.ВладелецНастроекПравОбъект");
	
	ТипыПодпискиЗаписатьНаборыЗначенийДоступа = УправлениеДоступомСлужебныйПовтИсп.ТипыОбъектовВПодпискахНаСобытия(
		"ЗаписатьНаборыЗначенийДоступа");
	
	ТипыПодпискиЗаписатьЗависимыеНаборыЗначенийДоступа = УправлениеДоступомСлужебныйПовтИсп.ТипыОбъектовВПодпискахНаСобытия(
		"ЗаписатьЗависимыеНаборыЗначенийДоступа");
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ВладелецПрав");
	ДополнительныеПараметры.Вставить("ОбщиеПраваВладельцев", Новый Соответствие);
	ДополнительныеПараметры.Вставить("ОтдельныеПраваВладельцев", Новый Соответствие);
	
	ИндексыПравВладельцев = Новый Соответствие;
	
	Для каждого ВозможноеПраво Из ВозможныеПрава Цикл
		ОбъектМетаданныхВладельца = Метаданные.НайтиПоПолномуИмени(ВозможноеПраво.ВладелецПрав);
		
		Если ОбъектМетаданныхВладельца = Неопределено Тогда
			ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не найден владелец прав ""%1"".'"),
				ВозможноеПраво.ВладелецПрав);
		КонецЕсли;
		
		ДополнительныеПараметры.ВладелецПрав = ВозможноеПраво.ВладелецПрав;
		
		ЗаполнитьИдентификаторы("ЧтениеВТаблицах",    ВозможноеПраво, ЗаголовокОшибки, ОтдельныеТаблицы, ДополнительныеПараметры);
		ЗаполнитьИдентификаторы("ИзменениеВТаблицах", ВозможноеПраво, ЗаголовокОшибки, ОтдельныеТаблицы, ДополнительныеПараметры);
		
		ПраваВладельца = ПоПолнымИменам[ВозможноеПраво.ВладелецПрав];
		Если ПраваВладельца = Неопределено Тогда
			ПраваВладельца = Новый Соответствие;
			МассивПравВладельца = Новый Массив;
			
			ТипСсылки = СтандартныеПодсистемыСервер.ТипСсылкиИлиКлючаЗаписиОбъектаМетаданных(
				ОбъектМетаданныхВладельца);
			
			ТипОбъекта = СтандартныеПодсистемыСервер.ТипОбъектаИлиНабораЗаписейОбъектаМетаданных(
				ОбъектМетаданныхВладельца);
			
			Если ОпределяемыйТипВладельцевПрав.Получить(ТипСсылки) = Неопределено Тогда
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Тип владельца прав ""%1""
					           |не указан в определяемом типе ""Владелец настроек прав"".'"),
					Строка(ТипСсылки));
			КонецЕсли;
			
			Если (ТипыПодпискиЗаписатьЗависимыеНаборыЗначенийДоступа.Получить(ТипОбъекта) <> Неопределено
			      ИЛИ ТипыПодпискиЗаписатьНаборыЗначенийДоступа.Получить(ТипОбъекта) <> Неопределено)
			    И ОпределяемыйТипЗначенийДоступа.Получить(ТипСсылки) = Неопределено Тогда
				
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Тип владельца прав ""%1""
					           |не указан в определяемом типе ""Значение доступа"",
					           |но используется для заполнения наборов значений доступа,
					           |т.к. указан в одной из подписок на событие:
					           |- ЗаписатьЗависимыеНаборыЗначенийДоступа*,
					           |- ЗаписатьНаборыЗначенийДоступа*.
					           |Требуется указать тип в определяемом типе ""Значение доступа""
					           |для корректного заполнения регистра НаборыЗначенийДоступа.'"),
					Строка(ТипСсылки));
			КонецЕсли;
			
			Если СвойстваВидовДоступа.ПоТипамЗначений.Получить(ТипСсылки) <> Неопределено Тогда
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Тип владельца прав ""%1""
					           |не может использоваться, как тип значений доступа,
					           |но обнаружен в описании вида доступа ""%2"".'"),
					Строка(ТипСсылки),
					СвойстваВидовДоступа.ПоТипамЗначений.Получить(ТипСсылки).Имя);
			КонецЕсли;
			
			Если СвойстваВидовДоступа.ПоТипамГруппИЗначений.Получить(ТипСсылки) <> Неопределено Тогда
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Тип владельца прав ""%1""
					           |не может использоваться, как тип групп значений доступа,
					           |но обнаружен в описании вида доступа ""%2"".'"),
					Строка(ТипСсылки),
					СвойстваВидовДоступа.ПоТипамЗначений.Получить(ТипСсылки).Имя);
			КонецЕсли;
			
			Если ТипыПодпискиОбновитьГруппыВладельцевНастроекПрав.Получить(ТипОбъекта) = Неопределено Тогда
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Тип владельца прав ""%1""
					           |не указан в определяемом типе ""Владелец настроек прав объект"".'"),
					Строка(ТипОбъекта));
			КонецЕсли;
			
			ПоПолнымИменам.Вставить(ВозможноеПраво.ВладелецПрав, ПраваВладельца);
			ПоТипамСсылок.Вставить(ТипСсылки,  МассивПравВладельца);
			ПоТипам.Вставить(ТипСсылки,  ПраваВладельца);
			ПоТипам.Вставить(ТипОбъекта, ПраваВладельца);
			Если ИерархическийОбъектМетаданных(ОбъектМетаданныхВладельца) Тогда
				ИерархическиеТаблицы.Вставить(ТипСсылки,  Истина);
				ИерархическиеТаблицы.Вставить(ТипОбъекта, Истина);
			КонецЕсли;
			
			ТипыВладельцев.Добавить(ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(
				ВозможноеПраво.ВладелецПрав).ПустаяСсылка());
				
			ИндексыПравВладельцев.Вставить(ВозможноеПраво.ВладелецПрав, 0);
		КонецЕсли;
		
		Если ПраваВладельца.Получить(ВозможноеПраво.Имя) <> Неопределено Тогда
			ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Для владельца прав ""%1""
				           |повторно определено право ""%2"".'"),
				ВозможноеПраво.ВладелецПрав,
				ВозможноеПраво.Имя);
		КонецЕсли;
		
		// Преобразования списков требуемых прав в массивы.
		Разделитель = "|";
		Для Индекс = 0 По ВозможноеПраво.ТребуемыеПрава.Количество()-1 Цикл
			Если СтрНайти(ВозможноеПраво.ТребуемыеПрава[Индекс], Разделитель) > 0 Тогда
				ВозможноеПраво.ТребуемыеПрава[Индекс] = СтрРазделить(
					ВозможноеПраво.ТребуемыеПрава[Индекс], Разделитель, Ложь);
			КонецЕсли;
		КонецЦикла;
		
		СвойстваВозможногоПрава = Новый Структура(
			"ВладелецПрав,
			|Имя,
			|Заголовок,
			|Подсказка,
			|НачальноеЗначение,
			|ТребуемыеПрава,
			|ЧтениеВТаблицах,
			|ИзменениеВТаблицах,
			|ИндексПрава");
		ЗаполнитьЗначенияСвойств(СвойстваВозможногоПрава, ВозможноеПраво);
		СвойстваВозможногоПрава.ИндексПрава = ИндексыПравВладельцев[ВозможноеПраво.ВладелецПрав];
		ИндексыПравВладельцев[ВозможноеПраво.ВладелецПрав] = СвойстваВозможногоПрава.ИндексПрава + 1;
		
		ПраваВладельца.Вставить(ВозможноеПраво.Имя, СвойстваВозможногоПрава);
		МассивПравВладельца.Добавить(СвойстваВозможногоПрава);
	КонецЦикла;
	
	// Дополнение отдельных таблиц.
	ОбщаяТаблица = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	Для каждого ОписаниеПрав Из ПоПолнымИменам Цикл
		ОтдельныеПрава = ДополнительныеПараметры.ОтдельныеПраваВладельцев.Получить(ОписаниеПрав.Ключ);
		Для каждого ОписаниеПрава Из ОписаниеПрав.Значение Цикл
			СвойстваПрава = ОписаниеПрава.Значение;
			Если СвойстваПрава.ИзменениеВТаблицах.Найти(ОбщаяТаблица) <> Неопределено Тогда
				Для каждого КлючИЗначение Из ОтдельныеТаблицы Цикл
					ОтдельнаяТаблица = КлючИЗначение.Ключ;
					
					Если ОтдельныеПрава.ИзменениеВТаблицах[ОтдельнаяТаблица] = Неопределено
					   И СвойстваПрава.ИзменениеВТаблицах.Найти(ОтдельнаяТаблица) = Неопределено Тогда
					
						СвойстваПрава.ИзменениеВТаблицах.Добавить(ОтдельнаяТаблица);
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ВозможныеПрава = Новый Структура;
	ВозможныеПрава.Вставить("ПоТипам",                       ПоТипам);
	ВозможныеПрава.Вставить("ПоТипамСсылок",                 ПоТипамСсылок);
	ВозможныеПрава.Вставить("ПоПолнымИменам",                ПоПолнымИменам);
	ВозможныеПрава.Вставить("ТипыВладельцев",                ТипыВладельцев);
	ВозможныеПрава.Вставить("ОтдельныеТаблицы",              ОтдельныеТаблицы);
	ВозможныеПрава.Вставить("ИерархическиеТаблицы",          ИерархическиеТаблицы);
	
	Возврат ОбщегоНазначения.ФиксированныеДанные(ВозможныеПрава);
	
КонецФункции

Процедура ЗаполнитьИдентификаторы(Свойство, ВозможноеПраво, ЗаголовокОшибки, ОтдельныеТаблицы, ДополнительныеПараметры)
	
	Если ДополнительныеПараметры.ОбщиеПраваВладельцев.Получить(ДополнительныеПараметры.ВладелецПрав) = Неопределено Тогда
		ОбщиеПрава     = Новый Структура("ЧтениеВТаблицах, ИзменениеВТаблицах", "", "");
		ОтдельныеПрава = Новый Структура("ЧтениеВТаблицах, ИзменениеВТаблицах", Новый Соответствие, Новый Соответствие);
		
		ДополнительныеПараметры.ОбщиеПраваВладельцев.Вставить(ДополнительныеПараметры.ВладелецПрав, ОбщиеПрава);
		ДополнительныеПараметры.ОтдельныеПраваВладельцев.Вставить(ДополнительныеПараметры.ВладелецПрав, ОтдельныеПрава);
	Иначе
		ОбщиеПрава     = ДополнительныеПараметры.ОбщиеПраваВладельцев.Получить(ДополнительныеПараметры.ВладелецПрав);
		ОтдельныеПрава = ДополнительныеПараметры.ОтдельныеПраваВладельцев.Получить(ДополнительныеПараметры.ВладелецПрав);
	КонецЕсли;
	
	Массив = Новый Массив;
	
	Для каждого Значение Из ВозможноеПраво[Свойство] Цикл
		
		Если Значение = "*" Тогда
			Если ВозможноеПраво[Свойство].Количество() <> 1 Тогда
				
				Если Свойство = "ЧтениеВТаблицах" Тогда
					ОписаниеОшибки =
						НСтр("ru = 'Для владельца прав ""%1""
						           |для права ""%2"" в таблицах для чтения указан символ ""*"".
						           |В этом случае отдельных таблиц указывать не нужно.'")
				Иначе
					ОписаниеОшибки =
						НСтр("ru = 'Для владельца прав ""%1""
						           |для права ""%2"" в таблицах для изменения указан символ ""*"".
						           |В этом случае отдельных таблиц указывать не нужно.'")
				КонецЕсли;
				
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ОписаниеОшибки, ДополнительныеПараметры.ВладелецПрав, ВозможноеПраво.Имя);
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ОбщиеПрава[Свойство]) Тогда
				
				Если Свойство = "ЧтениеВТаблицах" Тогда
					ОписаниеОшибки =
						НСтр("ru = 'Для владельца прав ""%1""
						           |для права ""%2"" в таблицах для чтения указан символ ""*"".
						           |Однако символ ""*"" уже указан в таблицах для чтения для права ""%3"".'")
				Иначе
					ОписаниеОшибки =
						НСтр("ru = 'Для владельца прав ""%1""
						           |для права ""%2"" в таблицах для изменения указан символ ""*"".
						           |Однако символ ""*"" уже указан в таблицах для изменения для права ""%3"".'")
				КонецЕсли;
				
				ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ОписаниеОшибки,
					ДополнительныеПараметры.ВладелецПрав, ВозможноеПраво.Имя, ОбщиеПрава[Свойство]);
			Иначе
				ОбщиеПрава[Свойство] = ВозможноеПраво.Имя;
			КонецЕсли;
			
			Массив.Добавить(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка());
			
		ИначеЕсли Свойство = "ЧтениеВТаблицах" Тогда
			ОписаниеОшибки =
				НСтр("ru = 'Для владельца прав ""%1""
				           |для права ""%2"" указана конкретная таблица для чтения ""%3"".
				           |Однако это не имеет смысла, т.к. право Чтение может зависеть только от права Чтение.
				           |Имеет смысл использовать только символ ""*"".'");
				
			ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ОписаниеОшибки,
				ДополнительныеПараметры.ВладелецПрав, ВозможноеПраво.Имя, Значение);
			
		ИначеЕсли Метаданные.НайтиПоПолномуИмени(Значение) = Неопределено Тогда
			
			Если Свойство = "ЧтениеВТаблицах" Тогда
				ОписаниеОшибки = НСтр("ru = 'Для владельца прав ""%1""
				                            |для права ""%2"" не найдена таблица для чтения ""%3"".'")
			Иначе
				ОписаниеОшибки = НСтр("ru = 'Для владельца прав ""%1""
				                            |для права ""%2"" не найдена таблица для изменения ""%3"".'")
			КонецЕсли;
			
			ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ОписаниеОшибки,
				ДополнительныеПараметры.ВладелецПрав, ВозможноеПраво.Имя, Значение);
		Иначе
			ИдентификаторТаблицы = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Значение);
			Массив.Добавить(ИдентификаторТаблицы);
			
			ОтдельныеТаблицы.Вставить(ИдентификаторТаблицы, Значение);
			ОтдельныеПрава[Свойство].Вставить(ИдентификаторТаблицы, ВозможноеПраво.Имя);
		КонецЕсли;
		
	КонецЦикла;
	
	ВозможноеПраво[Свойство] = Массив;
	
КонецПроцедуры

Функция ИерархическийОбъектМетаданных(ОписаниеОбъектаМетаданных)
	
	Если ТипЗнч(ОписаниеОбъектаМетаданных) = Тип("Строка") Тогда
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ОписаниеОбъектаМетаданных);
	ИначеЕсли ТипЗнч(ОписаниеОбъектаМетаданных) = Тип("Тип") Тогда
		ОбъектМетаданных = Метаданные.НайтиПоТипу(ОписаниеОбъектаМетаданных);
	Иначе
		ОбъектМетаданных = ОписаниеОбъектаМетаданных;
	КонецЕсли;
	
	Если ТипЗнч(ОбъектМетаданных) <> Тип("ОбъектМетаданных") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ Метаданные.Справочники.Содержит(ОбъектМетаданных)
	   И НЕ Метаданные.ПланыВидовХарактеристик.Содержит(ОбъектМетаданных) Тогда
		
		Возврат Ложь;
	КонецЕсли;
	
	Возврат ОбъектМетаданных.Иерархический;
	
КонецФункции

#КонецОбласти

#КонецЕсли
