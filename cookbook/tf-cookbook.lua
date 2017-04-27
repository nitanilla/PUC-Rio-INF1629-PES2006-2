-- tf-cookbook.lua
-- Autor: MV, RF
-- Versão: 0.1
-- Data da última modificação: 21/04/2017
-- Tamanho: 145 linhas

-- Dados mutáveis compartilhados
data = nil
words = nil
word_freqs = nil

-- Funções

-- Recebe um caminho para um arquivo e
-- armazena o conteúdo deste arquivo como uma string na variável global data
-- PRE: path_to_file é um caminho de arquivo válido (Verificação: existe uma assertiva garantindo isto)
-- POS: o conteúdo do arquivo lido foi armazenado como uma string na variável global data
-- (Verificação: a função read sempre retorna uma string referente ao conteúdo do arquivo aberto e esta string é armazenada na variável data)
function read_file(path_to_file)
	local file = io.open(path_to_file, "r")
	assert(file ~= nil, "Caminho do arquivo invalido")
	data = file:read("*all")
	file:close()
end

-- Substitui todos os caracteres não-alfanuméricos da variável global data por espaços
-- PRE: data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: data foi atualizado substituindo os caracteres não-alfanuméricos
-- por espaços, e as letras maiúsculas por letras minúsculas (Verificação: gsub('%W',' ') transforma os caracteres não-numéricos
-- em espaços em branco, e lower() transforma os caracteres maiúsculos em minúsculos)
function filter_chars_and_normalize()
	assert(data ~= nil, "A string que deveria ser filtrada esta nula no comeco da funcao filter_chars_and_normalize")
    data = data:gsub('%W',' '):lower()
end

-- Procura por palavras na string data, preenchendo o vetor de palavras `words´ (usando espaço em branco como separador)
-- PRE: data é uma string não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: a variável global words foi atualizada com as palavras da string data (Verificação: o for presente na função contém a função table.insert, que realiza isso)
function scan()
	assert(data ~= nil, "A string que deveria ser usada esta nula no comeco da funcao scan")
	local iterator = data:gmatch("%S+")
	words = {}

	for element in iterator do
	   table.insert(words, element)
	end
end

-- Remove as palavras ignoradas (stop words) do vetor (variável global) words
-- PRE: words é um vetor (variável global) e existe um arquivo no caminho "../stop_words.txt" (Verificação: existe uma assertiva garantindo isto)
-- POS: as palavras ignoradas (stop words) lidas no arquivo stop_words.txt foram removidas do vetor words (Verificação: o último for presente na função garante isso)
function remove_stop_words()
	assert(words ~= nil, "O vetor words esta nulo no inicio da funcao remove_stop_words")
	local file = io.open("../stop_words.txt", "r")
	local iterator = file:read("*all"):gmatch("([^,]+)")
	local stop_words = {}

	for element in iterator do
		table.insert(stop_words, element)
	end

	for ascii_code = 97, 122 do
		table.insert(stop_words, string.char(ascii_code))
	end

	for word_index = #words, 1, -1 do
		for stopword_key, stop_word in ipairs(stop_words) do
			local word = words[word_index]

			if(word == stop_word) then
				table.remove(words, word_index)
			end
		end
	end
end

-- Associa as palavras no vetor words a suas frequências de ocorrência, no vetor word_freqs
-- PRE: words é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: word_freqs foi preenchido com uma tabela associando cada palavra a sua frequência (Verificação: word_freqs é uma tabela, preenchida com estas informações, que é sempre atualizada)
function frequencies()
	assert(words ~= nil, "O vetor words esta nulo no inicio da funcao frequencies")
	word_freqs = {}

    for key, word in ipairs(words) do
        if word_freqs[word] ~= nil then
            word_freqs[word].frequency = word_freqs[word].frequency + 1
        else
            word_freqs[word] = {["word"] = word, ["frequency"] = 1}
		end
	end
end

-- Recebe uma tabela de palavras e suas frequências
-- e retorna um vetor com os valores da tabela, ordenados pela frequência
-- PRE: word_freqs é uma tabela não nula (Verificação: existe uma assertiva garantindo isto)
-- POS: o vetor word_freqs foi ordenado pela frequência (Verificação: a função table.sort realiza isso em um vetor temporário, que substitui o word_freqs)
function sort()
	assert(word_freqs ~= nil, "A tabela passada por referencia para a funcao sort esta nula")
	sorted_word_freqs = {}

	for key,element in pairs(word_freqs) do
		table.insert(sorted_word_freqs, element)
	end

	table.sort(sorted_word_freqs, function(a, b) return a.frequency > b.frequency end)

	word_freqs = sorted_word_freqs
end


-- Recebe um intervalo a ser filtrado,
-- e substitui o vetor word_freqs por um novo vetor contendo apenas os elementos do intervalo especificado
-- PRE: word_freqs não é nulo, range_min e range_max são números inteiros, range_min <= range_max (Verificação: existem assertivas garantindo isto)
-- POS: o vetor foi atualizado, e passou a conter apenas os elementos do intervalo especificado (Verificação: o for deste método itera sobre o intervalo
-- especificado e adiciona ao vetor que substitui word_freqs os elementos do intervalo)
function filter_word_freqs(range_min, range_max)
	assert(word_freqs ~= nil, "O vetor passado por referencia para a funcao filter_array esta nulo")
	assert(range_min <= range_max, "O segundo parametro (range_min) e maior que o terceiro (range_max)")

	filtered_array = {}

	for index = range_min, range_max do
		table.insert(filtered_array, word_freqs[index])
	end

	word_freqs = filtered_array
end

-- Imprime cada entrada do vetor word_freqs no formato "palavra" - "frequência", na ordem presente no vetor
-- PRE: word_freqs é um vetor não nulo (Verificação: existe uma assertiva garantindo isto)
-- POS: foram impressas todas as palavras/frequências presentes no vetor word_freqs (Verificação: o for presente na função realiza isso)
function print_all()
	assert(word_freqs ~= nil, "O vetor passado por referencia para a funcao print_all esta nulo")
	for key,element in ipairs(word_freqs) do
	   print(element.word .. " - " .. element.frequency)
	end
end

-- Programa
read_file(arg[1])
filter_chars_and_normalize()
scan()
remove_stop_words()
frequencies()
sort()
filter_word_freqs(0, 25)
print_all()
