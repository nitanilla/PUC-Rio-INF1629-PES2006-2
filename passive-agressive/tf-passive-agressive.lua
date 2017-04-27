-- tf-passive-agressive.lua
-- Autor: MV, RF
-- Vers�o: 0.1
-- Data da �ltima modifica��o: 21/04/2017
-- Tamanho: 145 linhas

-- Fun��es

-- Recebe um caminho para um arquivo e
-- retorna o conte�do deste arquivo como uma string
-- PRE: path_to_file � um caminho de arquivo v�lido (Verifica��o: existe uma assertiva garantindo isto)
-- POS: o conte�do do arquivo lido foi retornado como uma string (Verifica��o: a fun��o read sempre retorna uma string referente ao conte�do do arquivo aberto)
function read_file(path_to_file)
	assert(type(path_to_file) == "string", "O caminho passado nao eh uma string")
	local file = io.open(path_to_file, "r")
	assert(file ~= nil, "Caminho do arquivo invalido")
	local fileStr = file:read("*all")
	file:close()
	return fileStr
end

-- Recebe uma string e retorna uma c�pia sua onde
-- todos os caracteres n�o-alfanum�ricos foram substitu�dos por espa�os
-- PRE: str_data � uma string n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi retornada uma c�pia da string str_data, onde os caracteres n�o-alfanum�ricos
-- foram substitu�dos por espa�os, e as letras mai�sculas foram substitu�das por letras min�sculas (Verifica��o: gsub('%W',' ') transforma os caracteres n�o-num�ricos
-- em espa�os em branco, e lower() transforma os caracteres mai�sculos em min�sculos)
function filter_chars_and_normalize(str_data)
	assert(str_data ~= nil, "A string que deveria ser filtrada esta nula no comeco da funcao filter_chars_and_normalize")
    assert(type(str_data) == "string", "A string que deveria ser filtrada nao eh uma string no comeco da funcao filter_chars_and_normalize")
	return str_data:gsub('%W',' '):lower()
end

-- Recebe uma string e procura por palavras,
-- retornando um vetor de palavras (usando espa�o em branco como separador)
-- PRE: str_data � uma string n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor com as palavras da string str_data (Verifica��o: o for presente na fun��o cont�m a fun��o table.insert, que realiza isso)
function scan(str_data)
	assert(str_data ~= nil, "A string que deveria ser usada esta nula no comeco da funcao scan")
	assert(type(str_data) == "string", "A string que deveria ser usada nao eh uma string no comeco da funcao scan")
	local iterator = str_data:gmatch("%S+")
	local word_list = {}

	for element in iterator do
	   table.insert(word_list, element)
	end

	return word_list
end

-- Recebe um vetor de palavras e retorna uma c�pia sem
-- as palavras ignoradas (stop words)
-- PRE: word_list � um vetor n�o nulo e existe um arquivo no caminho "../stop_words.txt" (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor que n�o possui nenhum elemento que esteja presente no vetor (Verifica��o: o �ltimo for presente na fun��o garante isso)
-- de palavras ignoradas (stop words) lido no arquivo stop_words.txt
function remove_stop_words(word_list)
	assert(word_list ~= nil, "O vetor passado por referencia para a funcao remove_stop_words esta nulo")
	assert(type(word_list) == "table", "O vetor que deveria ser usado nao eh um table no comeco da funcao remove_stop_words")

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

	return word_list
end

-- Recebe um vetor de palavras e retorna uma tabela associando
-- palavras a suas frequ�ncias de ocorr�ncia
-- PRE: word_list � um vetor n�o nulo (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi retornada uma tabela contendo cada palavra associada a sua frequ�ncia (Verifica��o: word_freqs � uma tabela, preenchida com estas informa��es, que � sempre retornada)
function frequencies(word_list)
	assert(word_list ~= nil, "O vetor passado por referencia para a funcao frequencies esta nulo")
	assert(type(word_list) == "table", "O vetor passado por referencia para a funcao frequencies nao eh um table")

	word_freqs = {}

    for key, word in ipairs(word_list) do
        if word_freqs[word] ~= nil then
            word_freqs[word].frequency = word_freqs[word].frequency + 1
        else
            word_freqs[word] = {["word"] = word, ["frequency"] = 1}
		end
	end

    return word_freqs
end

-- Recebe uma tabela de palavras e suas frequ�ncias
-- e retorna um vetor com os valores da tabela, ordenados pela frequ�ncia
-- PRE: word_freq � uma tabela n�o nula (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor que cont�m os valores de word_freq, ordenados pela frequ�ncia (Verifica��o: a fun��o table.sort realiza isso)
function sort(word_freq)
	assert(word_freq ~= nil, "A tabela passada por referencia para a funcao sort esta nula")
	assert(type(word_freq) == "table", "O vetor passado por referencia para a funcao sort nao eh um table")

	sorted_word_freq = {}

	for key,element in pairs(word_freq) do
		table.insert(sorted_word_freq, element)
	end

	table.sort(sorted_word_freq, function(a, b) return a.frequency > b.frequency end)

	return sorted_word_freq
end


-- Recebe um vetor e um intervalo a ser filtrado,
-- e retorna uma novo vetor contendo apenas os elementos do intervalo especificado
-- PRE: input_array n�o � nulo, range_min e range_max s�o n�meros inteiros, range_min <= range_max (Verifica��o: existem assertivas garantindo isto)
-- POS: foi retornado o vetor contendo apenas os elementos do intervalo especificado (Verifica��o: o for deste m�todo itera sobre o intervalo
-- especificado e adiciona ao vetor que � retornado os elementos do intervalo)
function filter_array(input_array, range_min, range_max)
	assert(input_array ~= nil, "O vetor passado por referencia para a funcao filter_array esta nulo")
	assert(range_min <= range_max, "O segundo parametro (range_min) e maior que o terceiro (range_max)")
	assert(type(input_array) == "table", "input_array nao eh uma table")
	assert(type(range_min) == "number", "range_min nao eh um numero")
	assert(type(range_max) == "number", "range_max nao eh um numero")

	filtered_array = {}

	for index = range_min, range_max do
		table.insert(filtered_array, input_array[index])
	end

	return filtered_array
end

-- Recebe um vetor de palavras e frequ�ncias e imprime
-- cada entrada no formato "palavra" - "frequ�ncia", na ordem presente no vetor
-- PRE: word_freqs � um vetor n�o nulo (Verifica��o: existe uma assertiva garantindo isto)
-- POS: foram impressas todas as palavras/frequ�ncias presentes no vetor word_freqs (Verifica��o: o for presente na fun��o realiza isso)
function print_all(word_freqs)
	assert(word_freqs ~= nil, "O vetor passado por referencia para a funcao print_all esta nulo")
	assert(type(word_freqs) == "table", "word_freqs nao eh um table no inicio da funcao print_all")

	for key,element in ipairs(word_freqs) do
	   print(element.word .. " - " .. element.frequency)
	end
end

-- Programa
assert(arg[1] ~= nil, "Nao foi passado um caminho para o arquivo")

xpcall(function() print_all(filter_array(sort(frequencies(remove_stop_words(scan(filter_chars_and_normalize(read_file(arg[1])))))), 0, 25)) end, function(errorInfo) print("Erro: " .. errorInfo) end)
