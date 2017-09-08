﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ПоказатьНастройкиВнешнихПользователей = Параметры.ПоказатьНастройкиВнешнихПользователей;
	
	ПредлагаемыеЗначенияНастроек = Новый Структура;
	ПредлагаемыеЗначенияНастроек.Вставить("МинимальнаяДлинаПароля", 8);
	ПредлагаемыеЗначенияНастроек.Вставить("МаксимальныйСрокДействияПароля", 30);
	ПредлагаемыеЗначенияНастроек.Вставить("МинимальныйСрокДействияПароля", 1);
	ПредлагаемыеЗначенияНастроек.Вставить("ЗапретитьПовторениеПароляСредиПоследних", 10);
	ПредлагаемыеЗначенияНастроек.Вставить("ПросрочкаРаботыВПрограммеДоЗапрещенияВхода", 45);
	
	Если ПоказатьНастройкиВнешнихПользователей Тогда
		СтандартныеПодсистемыСервер.УстановитьКлючНазначенияФормы(ЭтотОбъект, "ВнешниеПользователи");
		АвтоЗаголовок = Ложь;
		Заголовок = НСтр("ru = 'Настройки входа внешних пользователей'");
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ПользователиСлужебный.НастройкиВхода().ВнешниеПользователи);
	Иначе
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ПользователиСлужебный.НастройкиВхода().Пользователи);
	КонецЕсли;
	
	Для Каждого КлючИЗначение Из ПредлагаемыеЗначенияНастроек Цикл
		Если ЗначениеЗаполнено(ЭтотОбъект[КлючИЗначение.Ключ]) Тогда
			ЭтотОбъект[КлючИЗначение.Ключ + "Включить"] = Истина;
		Иначе
			ЭтотОбъект[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
			Элементы[КлючИЗначение.Ключ].Доступность = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если ПолучитьПроверкуСложностиПаролейПользователей() Тогда
		ТекстВопросаОбОчисткеНастроекКонфигуратора = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Установлена минимальная длина паролей %1 и требование сложности паролей в конфигураторе
			           |в меню ""Администрирование"" в пункте ""Параметры информационной базы ..."".
			           |
			           |Требуется очистить минимальную длину и требование сложности пароля, заданные в конфигураторе,
			           |чтобы корректно использовать настройки входа.'"),
			ПолучитьМинимальнуюДлинуПаролейПользователей());
		
	ИначеЕсли ПолучитьМинимальнуюДлинуПаролейПользователей() > 0 Тогда
		ТекстВопросаОбОчисткеНастроекКонфигуратора = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Установлена минимальная длина паролей %1 в конфигураторе
			           |в меню ""Администрирование"" в пункте ""Параметры информационной базы ..."".
			           |
			           |Требуется очистить минимальную длину, заданную в конфигураторе,
			           |чтобы корректно использовать настройки входа.'"),
			ПолучитьМинимальнуюДлинуПаролейПользователей());
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ЗначениеЗаполнено(ТекстВопросаОбОчисткеНастроекКонфигуратора) Тогда
		Отказ = Истина;
		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить("Очистить", НСтр("ru = 'Очистить'"));
		Кнопки.Добавить("Отмена",   НСтр("ru = 'Отмена'"));
		ПоказатьВопрос(Новый ОписаниеОповещения("ПриОткрытииПослеОтветаНаВопрос", ЭтотОбъект),
			ТекстВопросаОбОчисткеНастроекКонфигуратора, Кнопки);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПарольДолженОтвечатьТребованиямСложностиПриИзменении(Элемент)
	
	Если МинимальнаяДлинаПароля < 7 Тогда
		МинимальнаяДлинаПароля = 7;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура МинимальнаяДлинаПароляПриИзменении(Элемент)
	
	Если МинимальнаяДлинаПароля < 7
	  И ПарольДолженОтвечатьТребованиямСложности Тогда
		
		МинимальнаяДлинаПароля = 7;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаВключитьПриИзменении(Элемент)
	
	ИмяНастройки = Лев(Элемент.Имя, СтрДлина(Элемент.Имя) - СтрДлина("Включить"));
	
	Если ЭтотОбъект[Элемент.Имя] = Ложь Тогда
		ЭтотОбъект[ИмяНастройки] = ПредлагаемыеЗначенияНастроек[ИмяНастройки];
	КонецЕсли;
	
	Элементы[ИмяНастройки].Доступность = ЭтотОбъект[Элемент.Имя];
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ЗаписатьНаСервере();
	Оповестить("Запись_НаборКонстант", Новый Структура, "НастройкиВходаПользователей");
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Продолжение процедуры ПриОткрытии.
&НаКлиенте
Процедура ПриОткрытииПослеОтветаНаВопрос(Ответ, Контекст) Экспорт
	
	Если Ответ <> "Очистить" Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопросаОбОчисткеНастроекКонфигуратора = "";
	
	ОчиститьНастройкиКонфигуратора();
	
	Открыть();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки  = Блокировка.Добавить("Константа.НастройкиВходаПользователей");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		НастройкиВхода = ПользователиСлужебный.НастройкиВхода();
		
		Если ПоказатьНастройкиВнешнихПользователей Тогда
			Настройки = НастройкиВхода.ВнешниеПользователи;
		Иначе
			Настройки = НастройкиВхода.Пользователи;
		КонецЕсли;
		
		Настройки.ПарольДолженОтвечатьТребованиямСложности = ПарольДолженОтвечатьТребованиямСложности;
		
		Если Не ЗначениеЗаполнено(ПросрочкаРаботыВПрограммеДоЗапрещенияВхода) Тогда
			Настройки.ПросрочкаРаботыВПрограммеДатаВключения = '00010101';
			
		ИначеЕсли Не ЗначениеЗаполнено(Настройки.ПросрочкаРаботыВПрограммеДатаВключения)
		      Или Не ЗначениеЗаполнено(Настройки.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода) Тогда
			
			Настройки.ПросрочкаРаботыВПрограммеДатаВключения = НачалоДня(ТекущаяДатаСеанса());
		КонецЕсли;
		
		Для Каждого КлючИЗначение Из ПредлагаемыеЗначенияНастроек Цикл
			Если ЭтотОбъект[КлючИЗначение.Ключ + "Включить"] Тогда
				Настройки[КлючИЗначение.Ключ] = ЭтотОбъект[КлючИЗначение.Ключ];
			Иначе
				Настройки[КлючИЗначение.Ключ] = 0;
			КонецЕсли;
		КонецЦикла;
		
		Константы.НастройкиВходаПользователей.Установить(Новый ХранилищеЗначения(НастройкиВхода));
		
		Если ЗначениеЗаполнено(НастройкиВхода.Пользователи.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода)
		 Или ЗначениеЗаполнено(НастройкиВхода.ВнешниеПользователи.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода) Тогда
			
			УстановитьПривилегированныйРежим(Истина);
			ПользователиСлужебный.ИзменитьЗаданиеКонтрольАктивностиПользователей(Истина);
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

&НаСервере
Процедура ОчиститьНастройкиКонфигуратора()
	
	НачатьТранзакцию();
	Попытка
		Если ПолучитьМинимальнуюДлинуПаролейПользователей() <> 0 Тогда
			УстановитьМинимальнуюДлинуПаролейПользователей(0);
		КонецЕсли;
		Если ПолучитьПроверкуСложностиПаролейПользователей() Тогда
			УстановитьПроверкуСложностиПаролейПользователей(Ложь);
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти
