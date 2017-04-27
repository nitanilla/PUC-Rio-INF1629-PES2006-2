-- tf-kick-forward.lua
-- Autor: MV, RF
-- Vers�o: 0.1
-- Data da �ltima modifica��o: 22/04/2017
-- Tamanho: 165 linhas

-- Fun��es

-- Recebe um caminho para um arquivo e
-- passa o conte�do deste arquivo como uma string para a fun��o recebida
-- PRE: path_to_file � um caminho de arquivo v�lido (Verifica��o: existe uma assertiva garantindo isto)
-- POS: o conte�do do arquivo lido foi passado como uma string para a fun��o recebida caso esta n�o seja nula (Verifica��o: a fun��o read sempre retorna uma string referente ao conte�do do arquivo aberto)
function read_file(path_to_file, func)
	local file = io.open(path_to_file, "r")
	assert(file ~= nil, "Caminho do arquivo invalido")
	local fileStr = file:read("*all")
	file:close()

	if(func ~= nil) then
		func(fileStr, scan)
	end
end

-- Recebe uma string e passa uma c�pia sua onde
-- todos os caracteres n�o-alfanum�ricos foram substitu�dos por espa�os para a fun��o recebida
-- PRE: str_data � uma string n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi criada uma c�pia da string str_data, onde os caracteres n�o-alfanum�ricos
-- foram substitu�dos por espa�os, e as letras mai�sculas foram substitu�das por letras min�sculas, e esta c�pia foi passada para a fun��o recebida caso a fun��o recebida n�o seja nula (Verifica��o: gsub('%W',' ') transforma os caracteres n�o-num�ricos
-- em espa�os em branco, e lower() transforma os caracteres mai�sculos em min�sculos)
function filter_chars_and_normalize(str_data, func)
	assert(str_data ~= nil, "A string que deveria ser filtrada esta nula no comeco da funcao filter_chars_and_normalize")

	if(func ~= nil) then
    	func(str_data:gsub('%W',' '):lower(), remove_stop_words)
	end
end

-- Recebe uma string e procura por palavras,
-- e passa um vetor de palavras (usando espa�o em branco como separador) para a fun��o recebida
-- PRE: str_data � uma string n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor com as palavras da string str_data, e este foi passado para a fun��o recebida caso esta n�o seja nula (Verifica��o: o for presente na fun��o cont�m a fun��o table.insert, que realiza isso)
function scan(str_data, func)
	assert(str_data ~= nil, "A string que deveria ser usada esta nula no comeco da funcao scan")
	local iterator = str_data:gmatch("%S+")
	local word_list = {}

	for element in iterator do
	   table.insert(word_list, element)
	end

	if(func ~= nil) then
		func(word_list, frequencies)
	end
end

-- Recebe um vetor de palavras e passa uma c�pia sem
-- as palavras ignoradas (stop words) para a fun��o recebida
-- PRE: word_list � um vetor n�o nulo e existe um arquivo no caminho "../stop_words.txt" (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor que n�o possui nenhum elemento que esteja presente no vetor de palavras ignoradas (stop words) lido no arquivo
-- stop_words.txt e esse vetor foi passado para a fun��o recebida caso esta n�o seja nula  (Verifica��o: o �ltimo for presente na fun��o garante isso)
function remove_stop_words(word_list, func)
	assert(word_list ~= nil, "O vetor passado por referencia para a funcao remove_stop_words esta nulo")
	local file = io.open("../stop_words.txt", "r")
	local iterator = file:read("*all"):gmatch("([^,]+)")
	local stop_words = {}

	for element in iterator do
		table.insert(stop_words, element)
	end

	for ascii_code = 97, 122 do
		table.insert(stop_words, string.char(ascii_code))
	end

	for word_index = #word_list, 1, -1 do
		for stopword_key, stop_word in ipairs(stop_words) do
			local word = word_list[word_index]

			if(word == stop_word) then
				table.remove(word_list, word_index)
			end
		end
	end

	if(func ~= nil) then
		func(word_list, sort)
	end
end

-- Recebe um vetor de palavras e passa uma tabela associando
-- palavras a suas frequ�ncias de ocorr�ncia para a fun��o recebida
-- PRE: word_list � um vetor n�o nulo (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi criada uma tabela contendo cada palavra associada a sua frequ�ncia, e esta tabela foi passada para a fun��o recebida caso a fun��o recebida n�o seja nula (Verifica��o: word_freqs � uma tabela criada na fun��o e preenchida com estas informa��es)
function frequencies(word_list, func)
	assert(word_list ~= nil, "O vetor passado por referencia para a funcao frequencies esta nulo")
	word_freqs = {}

    for key, word in ipairs(word_list) do
        if word_freqs[word] ~= nil then
            word_freqs[word].frequency = word_freqs[word].frequency + 1
        else
            word_freqs[word] = {["word"] = word, ["frequency"] = 1}
		end
	end

	if(func ~= nil) then
    	func(word_freqs, filter_array)
	end
end

-- Recebe uma tabela de palavras e suas frequ�ncias
-- e passa um vetor com os valores da tabela, ordenados pela frequ�ncia para a fun��o recebida
-- PRE: word_freq � uma tabela n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor que cont�m os valores de word_freq, ordenados pela frequ�ncia e este vetor foi passado para a fun��o recebida caso a fun��o recebida n�o seja nula (Verifica��o: a fun��o table.sort realiza isso)
function sort(word_freq, func)
	assert(word_freq ~= nil, "A tabela passada por referencia para a funcao sort esta nula")
	sorted_word_freq = {}

	for key,element in pairs(word_freq) do
		table.insert(sorted_word_freq, element)
	end

	table.sort(sorted_word_freq, function(a, b) return a.frequency > b.frequency end)

	if(func ~= nil) then
		func(sorted_word_freq, 0, 25, print_all)
	end
end


-- Recebe um vetor e um intervalo a ser filtrado,
-- e passa um novo vetor contendo apenas os elementos do intervalo especificado para a fun��o recebida
-- PRE: input_array n�o � nulo, range_min e range_max s�o n�meros inteiros, range_min <= range_max (Verifica��o: existem assertivas garantindo isto)
-- POS: foi criado um vetor contendo apenas os elementos do intervalo especificado, e este vetor foi passado para a fun��o recebida caso a fun��o recebida n�o seja nula (Verifica��o: o for deste m�todo itera sobre o intervalo
-- especificado e adiciona ao vetor que � retornado os elementos do intervalo)
function filter_array(input_array, range_min, range_max, func)
	assert(input_array ~= nil, "O vetor passado por referencia para a funcao filter_array esta nulo")
	assert(range_min <= range_max, "O segundo parametro (range_min) e maior que o terceiro (range_max)")

	filtered_array = {}

	for index = range_min, range_max do
		table.insert(filtered_array, input_array[index])
	end

	if(func ~= nil) then
		func(filtered_array, nil)
	end
end

-- Recebe um vetor de palavras e frequ�ncias e imprime
-- cada entrada no formato "palavra" - "frequ�ncia", na ordem presente no vetor. Passa o vetor de palavras e frequ�ncias para a fun��o recebida
-- PRE: word_freqs � um vetor n�o nulo (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foram impressas todas as palavras/frequ�ncias presentes no vetor word_freqs e este vetor foi passado para a fun��o recebida caso a fun��o recebida n�o seja nula (Verifica��o: o for presente na fun��o realiza isso)
function print_all(word_freqs, func)
	assert(word_freqs ~= nil, "O vetor passado por referencia para a funcao print_all esta nulo")
	for key,element in ipairs(word_freqs) do
	   print(element.word .. " - " .. element.frequency)
	end

	if(func ~= nil) then
		func(word_freqs, nil)
	end
end

-- Programa
read_file(arg[1], filter_chars_and_normalize)
