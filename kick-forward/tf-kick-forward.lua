-- tf-kick-forward.lua
-- Autor: MV, RF
-- Versão: 0.1
-- Data da última modificação: 22/04/2017
-- Tamanho: 165 linhas

-- Funções

-- Recebe um caminho para um arquivo e
-- passa o conteúdo deste arquivo como uma string para a função recebida
-- PRE: path_to_file é um caminho de arquivo válido (Verificação: existe uma assertiva garantindo isto)
-- POS: o conteúdo do arquivo lido foi passado como uma string para a função recebida caso esta não seja nula (Verificação: a função read sempre retorna uma string referente ao conteúdo do arquivo aberto)
function read_file(path_to_file, func)
	local file = io.open(path_to_file, "r")
	assert(file ~= nil, "Caminho do arquivo invalido")
	local fileStr = file:read("*all")
	file:close()

	if(func ~= nil) then
		func(fileStr, scan)
	end
end

-- Recebe uma string e passa uma cópia sua onde
-- todos os caracteres não-alfanuméricos foram substituídos por espaços para a função recebida
-- PRE: str_data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi criada uma cópia da string str_data, onde os caracteres não-alfanuméricos
-- foram substituídos por espaços, e as letras maiúsculas foram substituídas por letras minúsculas, e esta cópia foi passada para a função recebida caso a função recebida não seja nula (Verificação: gsub('%W',' ') transforma os caracteres não-numéricos
-- em espaços em branco, e lower() transforma os caracteres maiúsculos em minúsculos)
function filter_chars_and_normalize(str_data, func)
	assert(str_data ~= nil, "A string que deveria ser filtrada esta nula no comeco da funcao filter_chars_and_normalize")

	if(func ~= nil) then
    	func(str_data:gsub('%W',' '):lower(), remove_stop_words)
	end
end

-- Recebe uma string e procura por palavras,
-- e passa um vetor de palavras (usando espaço em branco como separador) para a função recebida
-- PRE: str_data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor com as palavras da string str_data, e este foi passado para a função recebida caso esta não seja nula (Verificação: o for presente na função contém a função table.insert, que realiza isso)
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

-- Recebe um vetor de palavras e passa uma cópia sem
-- as palavras ignoradas (stop words) para a função recebida
-- PRE: word_list é um vetor não nulo e existe um arquivo no caminho "../stop_words.txt" (Verificação: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor que não possui nenhum elemento que esteja presente no vetor de palavras ignoradas (stop words) lido no arquivo
-- stop_words.txt e esse vetor foi passado para a função recebida caso esta não seja nula  (Verificação: o último for presente na função garante isso)
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
-- palavras a suas frequências de ocorrência para a função recebida
-- PRE: word_list é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: foi criada uma tabela contendo cada palavra associada a sua frequência, e esta tabela foi passada para a função recebida caso a função recebida não seja nula (Verificação: word_freqs é uma tabela criada na função e preenchida com estas informações)
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

-- Recebe uma tabela de palavras e suas frequências
-- e passa um vetor com os valores da tabela, ordenados pela frequência para a função recebida
-- PRE: word_freq é uma tabela não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: foi criado um vetor que contém os valores de word_freq, ordenados pela frequência e este vetor foi passado para a função recebida caso a função recebida não seja nula (Verificação: a função table.sort realiza isso)
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
-- e passa um novo vetor contendo apenas os elementos do intervalo especificado para a função recebida
-- PRE: input_array não é nulo, range_min e range_max são números inteiros, range_min <= range_max (Verificação: existem assertivas garantindo isto)
-- POS: foi criado um vetor contendo apenas os elementos do intervalo especificado, e este vetor foi passado para a função recebida caso a função recebida não seja nula (Verificação: o for deste método itera sobre o intervalo
-- especificado e adiciona ao vetor que é retornado os elementos do intervalo)
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

-- Recebe um vetor de palavras e frequências e imprime
-- cada entrada no formato "palavra" - "frequência", na ordem presente no vetor. Passa o vetor de palavras e frequências para a função recebida
-- PRE: word_freqs é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: foram impressas todas as palavras/frequências presentes no vetor word_freqs e este vetor foi passado para a função recebida caso a função recebida não seja nula (Verificação: o for presente na função realiza isso)
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
