-- tf-pipeline.lua
-- Autor: MV, RF
-- Versão: 0.1
-- Data da última modificação: 21/04/2017
-- Tamanho: 145 linhas

-- Funções

-- Recebe um caminho para um arquivo e
-- retorna o conteúdo deste arquivo como uma string
-- PRE: path_to_file é um caminho de arquivo válido (Verificação: existe uma assertiva garantindo isto)
-- POS: o conteúdo do arquivo lido foi retornado como uma string (Verificação: a função read sempre retorna uma string referente ao conteúdo do arquivo aberto)
function read_file(path_to_file)
	local file = io.open(path_to_file, "r")
	assert(file ~= nil, "Caminho do arquivo invalido")
	local fileStr = file:read("*all")
	file:close()
	return fileStr
end

-- Recebe uma string e retorna uma cópia sua onde
-- todos os caracteres não-alfanuméricos foram substituídos por espaços
-- PRE: str_data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi retornada uma cópia da string str_data, onde os caracteres não-alfanuméricos
-- foram substituídos por espaços, e as letras maiúsculas foram substituídas por letras minúsculas (Verificação: gsub('%W',' ') transforma os caracteres não-numéricos
-- em espaços em branco, e lower() transforma os caracteres maiúsculos em minúsculos)
function filter_chars_and_normalize(str_data)
	assert(str_data ~= nil, "A string que deveria ser filtrada esta nula no comeco da funcao filter_chars_and_normalize")
    return str_data:gsub('%W',' '):lower()
end

-- Recebe uma string e procura por palavras,
-- retornando um vetor de palavras (usando espaço em branco como separador)
-- PRE: str_data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor com as palavras da string str_data (Verificação: o for presente na função contém a função table.insert, que realiza isso)
function scan(str_data)
	assert(str_data ~= nil, "A string que deveria ser usada esta nula no comeco da funcao scan")
	local iterator = str_data:gmatch("%S+")
	local word_list = {}

	for element in iterator do
	   table.insert(word_list, element)
	end

	return word_list
end

-- Recebe um vetor de palavras e retorna uma cópia sem
-- as palavras ignoradas (stop words)
-- PRE: word_list é um vetor não nulo e existe um arquivo no caminho "../stop_words.txt" (Verificação: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor que não possui nenhum elemento que esteja presente no vetor (Verificação: o último for presente na função garante isso)
-- de palavras ignoradas (stop words) lido no arquivo stop_words.txt
function remove_stop_words(word_list)
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

	return word_list
end

-- Recebe um vetor de palavras e retorna uma tabela associando
-- palavras a suas frequências de ocorrência
-- PRE: word_list é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: foi retornada uma tabela contendo cada palavra associada a sua frequência (Verificação: word_freqs é uma tabela, preenchida com estas informações, que é sempre retornada)
function frequencies(word_list)
	assert(word_list ~= nil, "O vetor passado por referencia para a funcao frequencies esta nulo")
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

-- Recebe uma tabela de palavras e suas frequências
-- e retorna um vetor com os valores da tabela, ordenados pela frequência
-- PRE: word_freq é uma tabela não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi retornado um vetor que contém os valores de word_freq, ordenados pela frequência (Verificação: a função table.sort realiza isso)
function sort(word_freq)
	assert(word_freq ~= nil, "A tabela passada por referencia para a funcao sort esta nula")
	sorted_word_freq = {}

	for key,element in pairs(word_freq) do
		table.insert(sorted_word_freq, element)
	end

	table.sort(sorted_word_freq, function(a, b) return a.frequency > b.frequency end)

	return sorted_word_freq
end


-- Recebe um vetor e um intervalo a ser filtrado,
-- e retorna uma novo vetor contendo apenas os elementos do intervalo especificado
-- PRE: input_array não é nulo, range_min e range_max são números inteiros, range_min <= range_max (Verificação: existem assertivas garantindo isto)
-- POS: foi retornado o vetor contendo apenas os elementos do intervalo especificado (Verificação: o for deste método itera sobre o intervalo
-- especificado e adiciona ao vetor que é retornado os elementos do intervalo)
function filter_array(input_array, range_min, range_max)
	assert(input_array ~= nil, "O vetor passado por referencia para a funcao filter_array esta nulo")
	assert(range_min <= range_max, "O segundo parametro (range_min) e maior que o terceiro (range_max)")

	filtered_array = {}

	for index = range_min, range_max do
		table.insert(filtered_array, input_array[index])
	end

	return filtered_array
end

-- Recebe um vetor de palavras e frequências e imprime
-- cada entrada no formato "palavra" - "frequência", na ordem presente no vetor
-- PRE: word_freqs é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: foram impressas todas as palavras/frequências presentes no vetor word_freqs (Verificação: o for presente na função realiza isso)
function print_all(word_freqs)
	assert(word_freqs ~= nil, "O vetor passado por referencia para a funcao print_all esta nulo")
	for key,element in ipairs(word_freqs) do
	   print(element.word .. " - " .. element.frequency)
	end
end

-- Programa
function main()
	print_all(filter_array(sort(frequencies(remove_stop_words(scan(filter_chars_and_normalize(read_file(arg[1])))))), 0, 25))
end

main()
