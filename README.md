# Dashboard Flutter Web

Dashboard web moderno construído com Flutter, seguindo os padrões do Material 3. A aplicação implementa uma arquitetura offline-first usando IndexedDB para persistência de dados no navegador, permitindo que o usuário trabalhe mesmo sem conexão com a internet.

## 📋 Índice

- [Como Rodar o Projeto](#-como-rodar-o-projeto)
- [Arquitetura do Projeto](#-arquitetura-do-projeto)
- [Bibliotecas Utilizadas](#-bibliotecas-utilizadas)
- [Features](#-features)
- [Estrutura de Pastas](#-estrutura-de-pastas)

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK 3.8.1 ou superior
- Dart SDK (incluído no Flutter)
- Navegador web moderno (Chrome, Firefox, Edge, Safari)

### Instalação

1. **Clone o repositório** (se aplicável):
   ```bash
   git clone <url-do-repositorio>
   cd dashboard_flutter_web
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o projeto**:
   ```bash
   flutter run -d chrome
   ```
   
   Ou para executar em modo web diretamente:
   ```bash
   flutter run -d web-server --web-port=8080
   ```

### Comandos Úteis

- **Executar em modo debug**: `flutter run -d chrome`
- **Executar em modo release**: `flutter run -d chrome --release`
- **Analisar código**: `flutter analyze`
- **Formatar código**: `flutter format .`
- **Executar testes**: `flutter test`
- **Limpar build**: `flutter clean`

### Build para Produção

Para gerar uma build otimizada para produção:

```bash
flutter build web --release
```

Os arquivos gerados estarão em `build/web/` e podem ser servidos por qualquer servidor web estático.

---

## 🏗️ Arquitetura do Projeto

A aplicação segue uma **arquitetura em camadas**, separando responsabilidades de forma clara:

```
┌─────────────────────────────────────┐
│         UI Layer                    │
│  (Widgets, Pages, Features)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      State Management Layer         │
│  (Cubit - Business Logic)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Data Layer                   │
│  (IndexedDB Service)                │
└─────────────────────────────────────┘
```

### Camadas

1. **UI Layer (Camada de Interface)**
   - Widgets reutilizáveis
   - Páginas de features
   - Componentes de layout (Header, Sidebar)
   - Componentes de gráficos

2. **State Management Layer (Camada de Gerenciamento de Estado)**
   - Cubits para lógica de negócio
   - Estados imutáveis
   - Gerenciamento reativo de dados

3. **Data Layer (Camada de Dados)**
   - Serviço IndexedDB (Singleton)
   - Modelos de dados
   - Operações CRUD
   - Persistência offline-first

### Padrões Utilizados

- **Singleton Pattern**: `IndexedDBService` garante uma única instância
- **Repository Pattern**: Abstração da camada de dados
- **BLoC/Cubit Pattern**: Gerenciamento de estado reativo
- **Observer Pattern**: `BlocBuilder` e `BlocListener` para reatividade

### Fluxo de Dados

```
User Action → Cubit Method → IndexedDB → New State → UI Update
```

**Exemplo completo:**
1. Usuário preenche formulário e clica em "Salvar"
2. `ItemDrawer` chama `cubit.createItem(item)`
3. `ItemCubit` emite `ItemLoading`
4. `ItemCubit` chama `_dbService.createItem(item)`
5. IndexedDB persiste o item
6. `ItemCubit` chama `loadItems()` para atualizar a lista
7. `ItemCubit` emite `ItemLoaded` com nova lista
8. UI atualiza automaticamente via `BlocBuilder`

---

## 📚 Bibliotecas Utilizadas

### Dependências Principais

| Biblioteca | Versão | Descrição |
|------------|--------|-----------|
| **flutter_bloc** | ^8.1.3 | Gerenciamento de estado reativo usando Cubit/Bloc |
| **go_router** | ^13.0.0 | Sistema de navegação declarativo e type-safe |
| **fl_chart** | ^0.69.0 | Biblioteca para criação de gráficos interativos |
| **idb_shim** | ^2.6.7 | Interface Dart para IndexedDB no navegador |

### Dependências de Desenvolvimento

| Biblioteca | Versão | Descrição |
|------------|--------|-----------|
| **flutter_lints** | ^5.0.0 | Conjunto de regras de lint recomendadas |

### Detalhamento das Bibliotecas

#### flutter_bloc
- **Uso**: Gerenciamento de estado da aplicação
- **Benefícios**: 
  - Estado previsível e testável
  - Separação de lógica de negócio da UI
  - Reatividade automática

#### go_router
- **Uso**: Navegação entre páginas
- **Benefícios**:
  - Rotas declarativas
  - Suporte a deep linking
  - Navegação type-safe
  - ShellRoute para layouts compartilhados

#### fl_chart
- **Uso**: Visualização de dados em gráficos
- **Benefícios**:
  - Gráficos interativos e animados
  - Suporte a múltiplos tipos (Line, Bar, Pie)
  - Customização avançada

#### idb_shim
- **Uso**: Persistência de dados no navegador
- **Benefícios**:
  - Armazenamento local robusto
  - Suporte a índices para buscas rápidas
  - Funciona offline
  - Persistência entre sessões

---

## 🎯 Features

### 1. Dashboard (`/dashboard`)

**Descrição**: Página principal com visão geral e métricas do sistema.

**Funcionalidades**:
- Cards de métricas (Total de Itens, Valor Total, Categorias, Status Ativos)
- Gráfico de linha mostrando tendência de valores acumulados
- Gráfico de barras com distribuição por categoria
- Gráfico de pizza com distribuição por status
- Layout responsivo (grid adapta-se ao tamanho da tela)

**Tecnologias**:
- `fl_chart` para visualização
- `BlocBuilder` para dados reativos
- Material 3 Cards

### 2. Tabela de Itens (`/products` ou `/table`)

**Descrição**: Página com tabela completa de itens, permitindo CRUD completo.

**Funcionalidades**:
- Tabela com ordenação por colunas (Nome, Categoria, Valor, Status, Data)
- Busca em tempo real por nome, descrição ou categoria
- Filtros por categoria e status
- Paginação (10 itens por página)
- Ações de edição e exclusão por linha
- Drawer lateral para criar/editar itens
- Validação de formulários
- Confirmação de exclusão

**Tecnologias**:
- `DataTable` do Material 3
- `ItemDrawer` para formulários
- `ItemCubit` para operações CRUD

### 3. Home (`/home`)

**Descrição**: Página inicial simples (em desenvolvimento).

**Status**: Placeholder para futuras implementações.

### 4. Customers (Clientes)

**Descrição**: Módulo de gerenciamento de clientes.

**Páginas**:
- **Customers Overview** (`/customers/overview`): Visão geral de clientes
- **Customers List** (`/customers/list`): Lista completa de clientes

**Status**: Em desenvolvimento - estrutura criada, implementação pendente.

### 5. Products (Produtos)

**Descrição**: Módulo de gerenciamento de produtos.

**Páginas**:
- **Products Dashboard** (`/products/dashboard`): Dashboard de produtos (usa `DashboardPage`)
- **Products Add** (`/products/add`): Adicionar novo produto
- **Products Draft** (`/products/draft`): Produtos em rascunho

**Status**: Em desenvolvimento - estrutura criada, implementação pendente.

### 6. Income (Receitas)

**Descrição**: Módulo de gerenciamento de receitas e finanças.

**Páginas**:
- **Income Statements** (`/income/statements`): Extratos de receita
- **Income Earnings** (`/income/earnings`): Ganhos
- **Income Payouts** (`/income/payouts`): Pagamentos
- **Income Refunds** (`/income/refunds`): Reembolsos

**Status**: Em desenvolvimento - estrutura criada, implementação pendente.

### 7. Shop (Loja)

**Descrição**: Página da loja (em desenvolvimento).

**Status**: Placeholder para futuras implementações.

### Features Globais

#### Tema Claro/Escuro
- Alternância entre tema claro e escuro
- Persistência da preferência do usuário
- `ThemeCubit` para gerenciamento do tema

#### Layout Responsivo
- **Desktop (>1024px)**: Sidebar expandida (250px), layout horizontal completo
- **Tablet (768-1024px)**: Sidebar colapsável (72px quando colapsada)
- **Mobile (<768px)**: Sidebar como drawer (abre/fecha)

#### Persistência Offline-First
- Todos os dados são salvos no IndexedDB
- Funciona completamente offline
- Sincronização automática quando online (futuro)

#### Navegação
- Menu lateral (Sidebar) com todas as rotas
- Header com logo e avatar do usuário
- Breadcrumbs (futuro)

---

## 📁 Estrutura de Pastas

```
lib/
├── main.dart                          # Entry point da aplicação
├── core/                              # Código central compartilhado
│   ├── database/
│   │   ├── indexed_db_service.dart    # Serviço IndexedDB (Singleton)
│   │   └── models/
│   │       └── item_model.dart        # Modelo de dados Item
│   └── theme/
│       └── app_theme.dart             # Configuração de temas (claro/escuro)
├── cubit/                             # Gerenciamento de estado
│   ├── item_cubit.dart                # Cubit para operações CRUD de itens
│   ├── item_state.dart                # Estados do ItemCubit
│   ├── theme_cubit.dart               # Cubit para gerenciamento de tema
│   └── theme_state.dart               # Estados do ThemeCubit
├── features/                          # Módulos de features
│   ├── dashboard/
│   │   └── dashboard_page.dart        # Página principal com gráficos
│   ├── table/
│   │   └── table_page.dart            # Página com tabela de itens
│   ├── home/
│   │   └── home_page.dart             # Página inicial
│   ├── customers/
│   │   ├── customers_overview_page.dart
│   │   └── customers_list_page.dart
│   ├── products/
│   │   ├── products_dashboard_page.dart
│   │   ├── products_add_page.dart
│   │   └── products_draft_page.dart
│   ├── income/
│   │   ├── income_statements_page.dart
│   │   ├── income_earning_page.dart
│   │   ├── income_payouts_page.dart
│   │   └── income_refunds_page.dart
│   ├── shop/
│   │   └── shop_page.dart
│   └── drawer/
│       └── item_drawer.dart           # Drawer para criar/editar itens
└── widgets/                           # Widgets reutilizáveis
    ├── layout/
    │   ├── app_layout.dart             # Layout principal (Header + Sidebar)
    │   ├── app_header.dart             # Header da aplicação
    │   ├── app_sidebar.dart            # Menu lateral
    │   ├── hexagonal_logo.dart         # Logo hexagonal
    │   ├── menu_item_model.dart        # Modelo de item do menu
    │   └── theme_switcher.dart         # Alternador de tema
    └── charts/
        └── chart_widgets.dart          # Widgets de gráficos (Line, Bar, Pie)
```

---

## 🛠️ Tecnologias e Ferramentas

- **Flutter**: Framework UI multiplataforma
- **Dart**: Linguagem de programação
- **Material 3**: Design system do Google
- **IndexedDB**: Banco de dados NoSQL do navegador
- **Cubit/Bloc**: State management reativo
- **GoRouter**: Sistema de navegação declarativo

---

## 📝 Notas de Desenvolvimento

### Boas Práticas Implementadas

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade clara
2. **Singleton Pattern**: `IndexedDBService` é um singleton para garantir uma única instância
3. **Imutabilidade**: Estados são imutáveis, facilitando debug
4. **Error Handling**: Todos os métodos têm tratamento de erro
5. **Validação**: Formulários têm validação completa
6. **Responsividade**: Layout adapta-se a diferentes tamanhos de tela
7. **Material 3**: Uso consistente dos componentes Material 3
8. **Offline-First**: Dados persistem localmente, funcionando sem internet

### Próximos Passos

- [ ] Implementar sincronização com backend
- [ ] Adicionar autenticação de usuários
- [ ] Completar implementação das features pendentes (Customers, Products, Income)
- [ ] Adicionar testes unitários e de integração
- [ ] Implementar exportação de dados (CSV, PDF)
- [ ] Adicionar mais tipos de gráficos
- [ ] Implementar notificações push
- [ ] Adicionar suporte a múltiplos idiomas (i18n)

---

## 📄 Licença

Este projeto é privado e de uso interno.

---

## 👥 Contribuição

Para contribuir com o projeto, siga os padrões de código estabelecidos e crie um pull request com uma descrição clara das mudanças.

---

**Desenvolvido com ❤️ usando Flutter**
