
-- Tabela Contas
CREATE TABLE Contas (
    ID_Conta INT PRIMARY KEY,
    Tipo_Conta VARCHAR(50) NOT NULL,
    Saldo DECIMAL(18,2) DEFAULT 0 NOT NULL,
    Data_Criacao DATE NOT NULL
);

-- Tabela Categorias
CREATE TABLE Categorias (
    ID_Categoria INT PRIMARY KEY,
    Nome_Categoria VARCHAR(100) NOT NULL,
    Tipo_Categoria VARCHAR(50) NOT NULL,
    Descricao_Categoria VARCHAR(255)
);

-- Tabela Centros de Custo
CREATE TABLE Centros_Custo (
    ID_CentroCusto INT PRIMARY KEY,
    Nome_CentroCusto VARCHAR(100) NOT NULL,
    Descricao_CentroCusto VARCHAR(255)
);

-- Tabela Forma de Pagamento
CREATE TABLE Forma_Pagamento (
    ID_FormaPagamento INT PRIMARY KEY,
    Tipo_FormaPagamento VARCHAR(50) NOT NULL,
    Nome_FormaPagamento VARCHAR(100) NOT NULL
);

-- Tabela Usuários
CREATE TABLE Usuarios (
    ID_Usuario INT PRIMARY KEY,
    Nome_Usuario VARCHAR(100) NOT NULL,
    Nivel_Acesso VARCHAR(50) NOT NULL,
    Data_Cadastro DATE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);

-- Tabela Transações
CREATE TABLE Transacoes (
    ID_Transacao INT PRIMARY KEY,
    ID_Conta INT NOT NULL,
    ID_Categoria INT NOT NULL,
    ID_CentroCusto INT,
    ID_FormaPagamento INT NOT NULL,
    ID_Usuario INT NOT NULL,
    Valor_Transacao DECIMAL(18,2) NOT NULL,
    Data_Transacao DATE NOT NULL,
    Descricao_Transacao VARCHAR(255),

    CONSTRAINT FK_Transacao_Conta FOREIGN KEY (ID_Conta) REFERENCES Contas(ID_Conta),
    CONSTRAINT FK_Transacao_Categoria FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID_Categoria),
    CONSTRAINT FK_Transacao_CentroCusto FOREIGN KEY (ID_CentroCusto) REFERENCES Centros_Custo(ID_CentroCusto),
    CONSTRAINT FK_Transacao_FormaPagamento FOREIGN KEY (ID_FormaPagamento) REFERENCES Forma_Pagamento(ID_FormaPagamento),
    CONSTRAINT FK_Transacao_Usuario FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario)
);

-- Criação de índices para melhorar consultas
CREATE INDEX IDX_Transacoes_Data ON Transacoes(Data_Transacao);
CREATE INDEX IDX_Contas_Tipo ON Contas(Tipo_Conta);
CREATE INDEX IDX_Categorias_Tipo ON Categorias(Tipo_Categoria);
CREATE INDEX IDX_Usuarios_Email ON Usuarios(Email);



-- Inserir dados em Contas
INSERT INTO Contas (ID_Conta, Tipo_Conta, Saldo, Data_Criacao)
VALUES 
(101, 'Corrente', 2000.50, '2022-07-15'),
(202, 'Corrente', 7500.00, '2021-09-05'),
(303, 'Poupanca', 15000.00, '2023-01-10');

-- Inserir dados em Categorias
INSERT INTO Categorias (ID_Categoria, Nome_Categoria, Tipo_Categoria, Descricao_Categoria)
VALUES 
(001, 'Aluguel', 'Despesa', 'Pagamento de aluguel'),
(002, 'Salario', 'Receita', 'Recebimento do salário'),
(003, 'Energia Eletrica', 'Despesa', 'Pagamento da conta de luz'),
(004, 'Venda de Produtos', 'Receita', 'Venda de produtos');

-- Inserir dados em Centros de Custo
INSERT INTO Centros_Custo (ID_CentroCusto, Nome_CentroCusto, Descricao_CentroCusto)
VALUES 
(301, 'Administrativo', 'Custos administrativos da empresa'),
(302, 'Operacional', 'Custos operacionais da empresa'),
(303, 'Marketing', 'Custos relacionados a campanhas e publicidade');

-- Inserir dados em Forma de Pagamento
INSERT INTO Forma_Pagamento (ID_FormaPagamento, Tipo_FormaPagamento, Nome_FormaPagamento)
VALUES 
(101, 'Cartao de Credito', 'Cartao Mastercard'),
(102, 'Transferencia Bancaria', 'PIX Itaú'),
(103, 'Dinheiro', 'Pagamento em especie'),
(104, 'Cheque', 'Pagamento com cheque');

-- Inserir dados em Usuarios
INSERT INTO Usuarios (ID_Usuario, Nome_Usuario, Nivel_Acesso, Data_Cadastro, Email)
VALUES 
(201, 'Rodrigo Cuencas', 'Administrador', '2021-03-10', 'rocuencas@gmail.com'),
(202, 'Barbara Cervigni', 'Usuário Comum', '2024-05-15', 'barbara.cervigni@gmail.com'),
(203, 'Pedro Lucas', 'Usuário Comum', '2023-02-01', 'p.lucas@oulook.com'),
(204, 'Ana Costa', 'Administrador', '2020-11-22', 'ana.costa@gmail.com');

-- Inserir dados em Transacoes
INSERT INTO Transacoes (ID_Transacao, ID_Conta, ID_Categoria, ID_CentroCusto, ID_FormaPagamento, ID_Usuario, Valor_Transacao, Data_Transacao, Descricao_Transacao)
VALUES 
(1001, 101, 001, 301, 102, 201, 1250.00, '2024-02-18', 'Pagamento de aluguel da sede'),
(1002, 202, 002, 302, 101, 202, 2500.00, '2024-04-13', 'Recebimento de salário do mês'),
(1003, 303, 003, 301, 103, 203, 480.45, '2024-11-05', 'Pagamento de energia eletrica'),
(1004, 101, 004, 303, 104, 204, 2500.00, '2023-02-15', 'Venda de produtos no varejo'),
(1005, 202, 001, 302, 101, 201, 1350.00, '2024-09-20', 'Pagamento de aluguel de depósito'),
(1006, 303, 004, 303, 102, 204, 8900.00, '2023-02-25', 'Venda de produtos industriais');






-- Calculo do saldo do fluxo de caixa

CREATE PROCEDURE CalcularSaldoFluxoCaixa
AS
BEGIN
    SELECT 
        (SUM(CASE WHEN Tipo_Categoria = 'Receita' THEN Valor_Transacao ELSE 0 END) -
         SUM(CASE WHEN Tipo_Categoria = 'Despesa' THEN Valor_Transacao ELSE 0 END)) AS Saldo_FluxoCaixa
    FROM Transacoes 
    INNER JOIN Categorias ON Transacoes.ID_Categoria = Categorias.ID_Categoria;
END;


-- Geracao de relatorios de receitas e despesas

CREATE PROCEDURE RelatorioReceitasDespesas
AS
BEGIN
    SELECT 
        Tipo_Categoria, 
        SUM(Valor_Transacao) AS Total
    FROM Transacoes 
    INNER JOIN Categorias ON Transacoes.ID_Categoria = Categorias.ID_Categoria
    GROUP BY Tipo_Categoria;
END;

-- Projecao do fluxo de caixa futuro

CREATE PROCEDURE ProjecaoFluxoCaixa (@meses INT)
AS
BEGIN
    SELECT 
        DATEADD(MONTH, @meses, GETDATE()) AS Data_Projecao,
        (SUM(CASE WHEN Tipo_Categoria = 'Receita' THEN Valor_Transacao ELSE 0 END) -
         SUM(CASE WHEN Tipo_Categoria = 'Despesa' THEN Valor_Transacao ELSE 0 END)) * @meses AS Projecao_FluxoCaixa
    FROM Transacoes 
    INNER JOIN Categorias ON Transacoes.ID_Categoria = Categorias.ID_Categoria;
END;

-- Validacao de dados de entrada

CREATE PROCEDURE ValidarTransacao
    @Valor_Transacao DECIMAL(10, 2),
    @ID_Conta INT,
    @ID_Categoria INT
AS
BEGIN
    IF @Valor_Transacao <= 0
        THROW 50000, 'O valor da transação deve ser maior que zero.', 1;

    IF NOT EXISTS (SELECT 1 FROM Contas WHERE ID_Conta = @ID_Conta)
        THROW 50001, 'A conta especificada não existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE ID_Categoria = @ID_Categoria)
        THROW 50002, 'A categoria especificada não existe.', 1;
END;




--  Calculo de juros compostos

CREATE FUNCTION CalcularJurosCompostos
(
    @Principal DECIMAL(10, 2),
    @Taxa DECIMAL(5, 2),
    @Periodos INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @Principal * POWER(1 + @Taxa / 100, @Periodos);
END;


-- Testando a procedure para calcular o saldo de fluxo de caixa

EXECUTE CalcularSaldoFluxoCaixa;


-- Testando a procedure de relatório de receitas e despesas

EXECUTE RelatorioReceitasDespesas;


-- Testando a projeção de fluxo de caixa para 6 meses

EXECUTE ProjecaoFluxoCaixa @meses = 6;


-- Testando a validação de transação

EXECUTE ValidarTransacao @Valor_Transacao = 200.00, @ID_Conta = 101, @ID_Categoria = 002;


-- Teste da funcao CalcularJurosCompostos

SELECT dbo.CalcularJurosCompostos(1000, 0.05, 12) AS ValorFinal;


--Criacao do gatilho para automatizacao do calculo do fluxo de caixa

CREATE TRIGGER Trigger_CalcularSaldoFluxoCaixa
ON Transacoes
AFTER INSERT, UPDATE
AS
BEGIN
   
    EXECUTE CalcularSaldoFluxoCaixa;

    PRINT 'O saldo do fluxo de caixa atual é:';
END;
