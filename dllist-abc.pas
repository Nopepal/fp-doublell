type
	TDLL = ^TDLL_Elem;
	TDLL_Elem = record
		Data: integer;		
		Prev, Next: TDLL;
	end;

procedure DLL_Free(var List: TDLL);
var
	Prev, Next, Buff: TDLL;
begin
	if (List <> nil) then
	begin
		Prev := List^.Prev;
		Next := List^.Next;
		while (Prev <> nil) do
		begin
			Buff := Prev^.Prev;
			Dispose(Prev);
			Prev := Buff;	
		end;
		while (Next <> nil) do
		begin
			Buff := Next^.Next;
			Dispose(Next);
			Next := Buff;
		end;
		Dispose(List);
		List := nil;
	end;	
end;

procedure DLL_PushForward(var List: TDLL; Data: integer);
var
	Buff, Elem: TDLL;
begin
	if (List <> nil) then
	begin
		Buff := List;
		while (Buff^.Prev <> nil) do
			Buff := Buff^.Prev;
		New(Elem);
		Elem^.Data := Data;
		Elem^.Next := Buff;
		Elem^.Prev := nil;
		Buff^.Prev := Elem;
		{
		* Список ориентирован влево. Левый элемент -- начальный.
		* Элементы добавляются влево.
		* Можно добавить схожую конструкцию в DLL_PushBack,
		* чтобы получить правоориентированный.
		}
		List := Elem;
		{
		* Конец конструкции.
		}
	end
	else
	begin
		New(List);
		List^.Data := Data;
		List^.Prev := nil;
		List^.Next := nil;
	end;
end;

procedure DLL_PushBack(var List: TDLL; Data: integer);
var
	Buff, Elem: TDLL;
begin
	if (List <> nil) then
	begin
		Buff := List;
		while (Buff^.Next <> nil) do
			Buff := Buff^.Next;
		New(Elem);
		Elem^.Data := Data;
		Elem^.Prev := Buff;
		Elem^.Next := nil;
		Buff^.Next := Elem;
	end
	else
	begin
		New(List);
		List^.Data := Data;
		List^.Prev := nil;
		List^.Next := nil;
	end;
end;

{
* Cледующая процедура -- переработка двух предыдущих. Для создания 
* Лево- или правоориентированного списка.
* Процедура сама решает, куда поставить элемент, если ей дан край 
* списка.
* Если край не дан, то она ничего не делает.
* По умолчанию, заполняет список справа налево. Возвращает последний
* левый добавленный элемент.
* n -> n-1 -> n-2 -> n-3 -> ... -> 0 -> nil
}

procedure DLL_Push(var List: TDLL; Data: integer);
var
	Elem: TDLL;
begin
	if (List <> nil) then
	begin
		if (List^.Prev = nil) then
		begin
			New(Elem);
			Elem^.Data := Data;
			Elem^.Next := List;
			Elem^.Prev := nil;
			List^.Prev := Elem;
			List := Elem;
		end
		else
			if(List^.Next = nil) then
			begin
				New(Elem);
				Elem^.Data := Data;
				Elem^.Next := nil;
				Elem^.Prev := List;
				List^.Next := Elem;
				List := Elem;
			end;	
	end
	else
	begin
		New(List);
		List^.Data := Data;
		List^.Prev := nil;
		List^.Next := nil;
	end;
	
end;

{
* Вывод слева направо.
}
procedure DLL_Print(List: TDLL);
begin
	while (List^.Prev <> nil) do
		List := List^.Prev;
	while (List <> nil) do
	begin
		Write(List^.Data, ' ');
		List := List^.Next;
	end;
end;

{
* Меняет два элемента местами.
}
procedure DLL_Swap(Elem1, Elem2: TDLL);
var
	Buff: TDLL; 
begin
	if (Elem1 <> nil) and (Elem2 <> nil) then
	begin
		New(Buff);

		Buff^ := Elem1^;
		Elem1^ := Elem2^;
		Elem2^ := Buff^;
		
		Elem2^.Prev := Elem1^.Prev;
		Elem2^.Next := Elem1^.Next;
		Elem1^.Prev := Buff^.Prev;
		Elem1^.Next := Buff^.Next;
		
		Dispose(Buff);
	end;
end;

{
* Получить n-й элемент списка. 
* Нумерация с 1.
* Есть защита от выхода за пределы. При выходе возвращает nil.
* TODO: Коды ошибок. Их нет, а защита есть. Можно как упражнение.
* Интеллектуально определяет направление счёта.
* Prev = nil => Слева направо, иначе если Next = nil справа налево.
}
function DLL_Get(List: TDLL; ElemNum: longint): TDLL;
var
	i: longint;
begin
	if (List <> nil) then
	begin
		if (List^.Prev = nil) then
		begin
			for i := 2 to ElemNum do
			begin
				if (List = nil) then
				begin
				  Result := nil;
				  Exit;
				end;
				List := List^.Next;
			end;
			Result := List;
			Exit;
		end
		else
			if (List^.Next = nil) then
			begin
				for i := 2 to ElemNum do
				begin
					if (List = nil) then
					begin
					  Result := nil;
					  Exit;
					end;
					List := List^.Prev;
				end;
				Result := List;
				Exit;
			end; 	
	end;
	{
	* Пустой список или начальный аргумент -- не конец списка.
	}
	Result := nil;
	Exit;
end;

{
* Перемешивает список. Принимает левый конец.
* Принимает длину списка. Сложность: O(n)
* Тасование Фишера-Йетса.
* Зависит от: DLL_Swap, DLL_Get
* Защита от выхода за пределы -- в DLL_Get.
* TODO: Коды ошибок. Непонятно, оттасовали или нет? Можно как упражнение.
}
procedure DLL_Shuffle(List: TDLL; Len: longint);
var
	i, j: longint;
begin
	Randomize;
	for i := Len - 1 downto 0 do
	begin
		j := random(i + 1);
		DLL_Swap(DLL_Get(List, j + 1), DLL_Get(List, i + 1));
	end;
end;

procedure DLL_Delete(var List: TDLL; ElemNum: longint);
var
	Elem, Del: TDLL;
	i: longint;
begin
	Del := nil;
	if (List <> nil) then
	begin
		if (List^.Prev = nil) then
		begin
			if (ElemNum = 1) then
			begin
				Del := List;
				List := List^.Next;
				if (List <> nil) then
					List^.Prev := nil;
			end
			else
			begin
				Elem := List;
				for i := 2 to ElemNum do
				begin
					if (Elem = nil) then
						break;
					Elem := Elem^.Next;
				end;
				if (Elem <> nil) then
				begin
					Elem^.Prev^.Next := Elem^.Next;
					if (Elem^.Next <> nil) then
						Elem^.Next^.Prev := Elem^.Prev;
					Del := Elem;
				end;
			end;
		end
		else
			if (List^.Next = nil) then
			begin
				if (ElemNum = 1) then
				begin
					Del := List;
					List := List^.Prev;
					if (List <> nil) then
						List^.Next := nil;
				end
				else
				begin
					Elem := List;
					for i := 2 to ElemNum do
					begin
						if (Elem = nil) then
						Elem := Elem^.Prev;
					end;
					if (Elem <> nil) then
					begin
						if (Elem^.Prev <> nil) then
							Elem^.Prev^.Next := Elem^.Next;
						Elem^.Next^.Prev := Elem^.Prev;
						Del := Elem;
					end;
				end;
			end; 
	end;
	if (Del <> nil) then
		dispose(Del);
end;

var
	List, ListEnd: TDLL;

begin
	DLL_PushForward(List, 100);
	DLL_PushForward(List, 200);
	DLL_PushForward(List, 300);
	DLL_PushForward(List, 400);
	DLL_Print(List); 		{400 300 200 100}
	Writeln;
	DLL_PushBack(List, 500);
	DLL_PushBack(List, 600);
	DLL_Print(List);		{400 300 200 100 500 600}
	Writeln;
	Writeln(List^.Data);		{400}
	ListEnd := List;
	while (ListEnd^.Next <> nil) do
		ListEnd := ListEnd^.Next;
	DLL_Push(ListEnd, 700);
	DLL_Print(List);		{400 300 200 100 500 600 700}
	Writeln;
	DLL_Push(List, 800);
	DLL_Print(List);		{800 400 300 200 100 500 600 700}
	Writeln;
	DLL_Swap(List, ListEnd);
	DLL_Print(List);		{700 400 300 200 100 500 600 800}
	Writeln;
	Writeln(DLL_Get(List, 5)^.Data);	{100}
	Writeln(DLL_Get(ListEnd, 8)^.Data);	{700}
	if (DLL_Get(ListEnd, 9) = nil) then 
		Writeln('OOL Protection!');	{OOL Protection!}
	DLL_Print(List);		{8 элементов от 100 до 800 как было}
	Writeln;	
	DLL_Shuffle(List, 8);
	DLL_Print(List);		{8 элементов от 100 до 800 случайно}
	Writeln;
end.
