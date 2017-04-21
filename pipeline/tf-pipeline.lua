-- tf-pipeline.lua
-- Autor: MV, RF
-- Vers�o: 0.1
-- Data da �ltima modifica��o: 21/04/2017
-- Tamanho: 125 linhas

-- Fun��es

-- Recebe um caminho para um arquivo e 
-- retorna o conte�do deste arquivo como uma string
-- PRE: path_to_file � um caminho de arquivo v�lido
-- POS: o conte�do do arquivo lido foi retornado como uma string
function read_file(path_to_file)
	local file = io.open(path_to_file, "r")
	local fileStr = file:read("*all")
	file:close()
	return fileStr
end

-- Recebe uma string e retorna uma c�pia sua onde
-- todos os caracteres n�o-alfanum�ricos foram substitu�dos por espa�os
-- PRE: str_data � uma string n�o nula
-- POS: foi retornada uma c�pia da string str_data, onde os caracteres n�o-alfanum�ricos
-- foram substitu�dos por espa�os, e as letras mai�sculas foram substitu�das por letras min�sculas
function filter_chars_and_normalize(str_data)
    return str_data:gsub('%W',' '):lower()
end

-- Recebe uma string e procura por palavras,
-- retornando um vetor de palavras
-- PRE: str_data � uma string n�o nula
-- POS: foi retornado um vetor com as palvras da string str_data
-- (usando espa�o em branco como separados)
function scan(str_data)
	local iterator = str_data:gmatch("%S+")
	local word_list = {}
	
	for element in iterator do
	   table.insert(word_list, element)
	end
	
	return word_list
end

-- Recebe um vetor de palavras e retorna uma c�pia sem
-- as palavras ignoradas (stop words)
-- PRE: word_list � um vetor n�o nulo e existe um arquivo no caminho "../stop_words.txt"
-- POS: foi retornado um vetor que n�o possui nenhum elemento que esteja presente no vetor
-- de palavras ignoradas (stop words) lido no arquivo stop_words.txt
function remove_stop_words(word_list)
	local file = io.open("../stop_words.txt", "r")
	local iterator = file:read("*all"):gmatch("([^,]+)")
	local stop_words = {}
	
	for element in iterator do
		table.insert(stop_words, element)
	end
	
	for ascii_code = 97, 122 do 
		table.insert(stop_words, string.char(ascii_code))
	end
	
	for word_key, word in ipairs(word_list) do
		for stopword_key, stop_word in ipairs(stop_words) do
			if(word == stop_word) then
				table.remove(word_list, word_key)
			end
		end
	end
	
	return word_list
end

-- Recebe um vetor de palavras e retorna uma tabela associando
-- palavras a suas frequ�ncias de ocorr�ncia
-- PRE: word_list � um vetor n�o nulo
-- POS: foi retornada uma tabela contendo cada palavra associada a sua frequ�ncia
function frequencies(word_list)
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
-- PRE: word_freq � uma tabela n�o nula
-- POS: foi retornado um vetor que cont�m os valores de word_freq, ordenados pela frequ�ncia
function sort(word_freq)
	sorted_word_freq = {}
	
	for key,element in pairs(word_freq) do
		table.insert(sorted_word_freq, element)
	end
	
	table.sort(sorted_word_freq, function(a, b) return a.frequency > b.frequency end)
	
	return sorted_word_freq
end

-- Recebe um vetor de palavras e frequ�ncias e imprime
-- cada entrada no formato "palavra" - "frequ�ncia", na ordem presente no vetor
-- PRE: word_freqs � um vetor n�o nulo
-- POS: foram impressas todas as palavras/frequ�ncias presentes no vetor word_freqs
function print_all(word_freqs)
	for key,element in ipairs(word_freqs) do
	   print(element.word .. " - " .. element.frequency)
	end
end

-- Recebe um vetor e um intervalo a ser filtrado, 
-- e retorna uma novo vetor contendo apenas os elementos do intervalo especificado
-- PRE: range_min e range_max s�o n�meros inteiros, input_array � um vetor n�o nulo de tamanho >= range_max, range_min <= range_max
function filter_array(input_array, range_min, range_max)
	filtered_array = {}
	
	for index = range_min, range_max do
		table.insert(filtered_array, input_array[index])
	end
	
	return filtered_array
end

-- Programa
print_all(filter_array(sort(frequencies(remove_stop_words(scan(filter_chars_and_normalize(read_file(arg[0])))))), 0, 25))