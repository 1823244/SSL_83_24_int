﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем ОшибкаРасчетаКурсаПоФормуле;

#КонецОбласти

#Область ОбработчикиСобытий

// При записи контролируются курсы подчиненных валют.
//
Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.Свойство("ОтключитьКонтрольПодчиненныхВалют") Тогда
		Возврат;
	КонецЕсли;
		
	ДополнительныеСвойства.Вставить("ЗависимыеВалюты", Новый Соответствие);
	
	Если Количество() > 0 Тогда
		ОбновитьКурсыПодчиненныхВалют();
	Иначе
		УдалитьКурсыПодчиненныхВалют();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Находит все зависимые валюты и изменяет их курс.
//
Процедура ОбновитьКурсыПодчиненныхВалют()
	
	ЗависимаяВалюта = Неопределено;
	ДополнительныеСвойства.Свойство("ОбновитьКурсЗависимойВалюты", ЗависимаяВалюта);
	Если ЗависимаяВалюта <> Неопределено Тогда
		ЗависимаяВалюта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЗависимаяВалюта, 
			"Ссылка,Наценка,СпособУстановкиКурса,ФормулаРасчетаКурса");
	КонецЕсли;
	
	Для Каждого ЗаписьОсновнойВалюты Из ЭтотОбъект Цикл

		Если ЗависимаяВалюта <> Неопределено Тогда // Нужно обновить курс только указанной валюты.
			ОбновленныеПериоды = Неопределено;
			Если Не ДополнительныеСвойства.Свойство("ОбновленныеПериоды", ОбновленныеПериоды) Тогда
				ОбновленныеПериоды = Новый Соответствие;
				ДополнительныеСвойства.Вставить("ОбновленныеПериоды", ОбновленныеПериоды);
			КонецЕсли;
			// Повторно не обновляем курс за один и тот же период.
			Если ОбновленныеПериоды[ЗаписьОсновнойВалюты.Период] = Неопределено Тогда
				ОбновитьКурсЗависимойВалюты(ЗависимаяВалюта, ЗаписьОсновнойВалюты); 
				ОбновленныеПериоды.Вставить(ЗаписьОсновнойВалюты.Период, Истина);
			КонецЕсли;
		Иначе	// Обновить курс всех зависимых валют.
			ЗависимыеВалюты = РаботаСКурсамиВалют.СписокЗависимыхВалют(ЗаписьОсновнойВалюты.Валюта, ДополнительныеСвойства);
			Для Каждого ЗависимаяВалюта Из ЗависимыеВалюты Цикл
				ОбновитьКурсЗависимойВалюты(ЗависимаяВалюта, ЗаписьОсновнойВалюты); 
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбновитьКурсЗависимойВалюты(ЗависимаяВалюта, ЗаписьОсновнойВалюты)
	
	НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Валюта.Установить(ЗависимаяВалюта.Ссылка, Истина);
	НаборЗаписей.Отбор.Период.Установить(ЗаписьОсновнойВалюты.Период, Истина);
	
	ЗаписьКурсовВалют = НаборЗаписей.Добавить();
	ЗаписьКурсовВалют.Валюта = ЗависимаяВалюта.Ссылка;
	ЗаписьКурсовВалют.Период = ЗаписьОсновнойВалюты.Период;
	Если ЗависимаяВалюта.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты Тогда
		ЗаписьКурсовВалют.Курс = ЗаписьОсновнойВалюты.Курс + ЗаписьОсновнойВалюты.Курс * ЗависимаяВалюта.Наценка / 100;
		ЗаписьКурсовВалют.Кратность = ЗаписьОсновнойВалюты.Кратность;
	Иначе // по формуле
		Курс = КурсВалютыПоФормуле(ЗависимаяВалюта.Ссылка, ЗависимаяВалюта.ФормулаРасчетаКурса, ЗаписьОсновнойВалюты.Период);
		Если Курс <> Неопределено Тогда
			ЗаписьКурсовВалют.Курс = Курс;
			ЗаписьКурсовВалют.Кратность = 1;
		КонецЕсли;
	КонецЕсли;
		
	НаборЗаписей.ДополнительныеСвойства.Вставить("ОтключитьКонтрольПодчиненныхВалют");
	НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
	
	Если ЗаписьКурсовВалют.Курс > 0 Тогда
		НаборЗаписей.Записать();
	КонецЕсли;
	
КонецПроцедуры	

// Очищает курсы зависимых валют.
//
Процедура УдалитьКурсыПодчиненныхВалют()
	
	ВалютаВладелец = Отбор.Валюта.Значение;
	Период = Отбор.Период;
	
	ЗависимаяВалюта = Неопределено;
	Если ДополнительныеСвойства.Свойство("ОбновитьКурсЗависимойВалюты", ЗависимаяВалюта) Тогда
		УдалитьКурсыВалюты(ЗависимаяВалюта, Период);
	Иначе
		ЗависимыеВалюты = РаботаСКурсамиВалют.СписокЗависимыхВалют(ВалютаВладелец, ДополнительныеСвойства);
		Для Каждого ЗависимаяВалюта Из ЗависимыеВалюты Цикл
			УдалитьКурсыВалюты(ЗависимаяВалюта.Ссылка, Период);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура УдалитьКурсыВалюты(ВалютаСсылка, Период)
	НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Валюта.Установить(ВалютаСсылка);
	НаборЗаписей.Отбор.Период.Установить(Период);
	НаборЗаписей.ДополнительныеСвойства.Вставить("ОтключитьКонтрольПодчиненныхВалют");
	НаборЗаписей.Записать();
КонецПроцедуры
	
Функция КурсВалютыПоФормуле(Валюта, Формула, Период)
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Валюты.Наименование КАК СимвольныйКод,
	|	ЕСТЬNULL(КурсыВалютСрезПоследних.Курс, 1) / ЕСТЬNULL(КурсыВалютСрезПоследних.Кратность, 1) КАК Курс
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(&Период, ) КАК КурсыВалютСрезПоследних
	|		ПО КурсыВалютСрезПоследних.Валюта = Валюты.Ссылка
	|ГДЕ
	|	Валюты.СпособУстановкиКурса <> ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты)
	|	И Валюты.СпособУстановкиКурса <> ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.РасчетПоФормуле)";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Период", Период);
	Выражение = СтрЗаменить(Формула, ",", ".");
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Выражение = СтрЗаменить(Выражение, Выборка.СимвольныйКод, Формат(Выборка.Курс, "ЧРД=.; ЧГ=0"));
	КонецЦикла;
	
	Попытка
		Результат = ОбщегоНазначения.ВычислитьВБезопасномРежиме(Выражение);
	Исключение
		Если ОшибкаРасчетаКурсаПоФормуле = Неопределено Тогда
			ОшибкаРасчетаКурсаПоФормуле = Новый Соответствие;
		КонецЕсли;
		Если ОшибкаРасчетаКурсаПоФормуле[Валюта] = Неопределено Тогда
			ОшибкаРасчетаКурсаПоФормуле.Вставить(Валюта, Истина);
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Расчет курса валюты ""%1"" по формуле ""%2"" не выполнен:'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), Валюта, Формула);
				
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки + Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке), 
				Валюта, "Объект.ФормулаРасчетаКурса");
				
			Если ДополнительныеСвойства.Свойство("ОбновитьКурсЗависимойВалюты") Тогда
				ВызватьИсключение ТекстОшибки + Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
			Иначе
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Валюты.Загрузка курсов валют'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Ошибка, Валюта.Метаданные(), Валюта, 
					ТекстОшибки + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
			КонецЕсли;
		КонецЕсли;
		Результат = Неопределено;
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

#КонецОбласти

#КонецЕсли