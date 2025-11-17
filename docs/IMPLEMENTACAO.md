# Documentação Técnica - Dashboard Flutter Web Material 3

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura da Aplicação](#arquitetura-da-aplicação)
3. [Estrutura de Pastas](#estrutura-de-pastas)
4. [Componentes Principais](#componentes-principais)
5. [IndexedDB - Persistência Offline-First](#indexeddb---persistência-offline-first)
6. [State Management com Cubit](#state-management-com-cubit)
7. [Material 3 Components](#material-3-components)
8. [Navegação com GoRouter](#navegação-com-gorouter)
9. [Responsividade](#responsividade)
10. [Fluxo de Dados](#fluxo-de-dados)

---

## Visão Geral

Esta aplicação é um dashboard web construído com Flutter, seguindo os padrões do Material 3. A aplicação implementa uma arquitetura offline-first usando IndexedDB para persistência de dados no navegador, permitindo que o usuário trabalhe mesmo sem conexão com a internet.

### Tecnologias Utilizadas

- **Flutter**: Framework UI multiplataforma
- **Material 3**: Design system do Google
- **IndexedDB**: Banco de dados NoSQL do navegador
- **Cubit (flutter_bloc)**: State management reativo
- **GoRouter**: Sistema de navegação declarativo
- **fl_chart**: Biblioteca para criação de gráficos interativos

---

## Arquitetura da Aplicação

A aplicação segue uma arquitetura em camadas, separando responsabilidades:

```
┌─────────────────────────────────────┐
│         UI Layer                  │
│  (Widgets, Pages, Features)         │
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

1. **UI Layer**: Widgets e páginas que compõem a interface
2. **State Management Layer**: Lógica de negócio e gerenciamento de estado
3. **Data Layer**: Persistência de dados no IndexedDB

---

## Estrutura de Pastas

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── database/
│   │   ├── indexed_db_service.dart    # Serviço IndexedDB
│   │   └── models/
│   │       └── item_model.dart        # Modelo de dados
│   └── theme/
│       └── app_theme.dart             # Configuração do tema
├── cubit/
│   ├── item_cubit.dart                # Cubit para CRUD
│   └── item_state.dart                # Estados do Cubit
├── features/
│   ├── dashboard/
│   │   └── dashboard_page.dart        # Página com gráficos
│   ├── table/
│   │   └── table_page.dart            # Página com tabela
│   └── drawer/
│       └── item_drawer.dart           # Drawer de edição
└── widgets/
    ├── layout/
    │   ├── app_layout.dart             # Layout principal
    │   ├── app_header.dart             # Header
    │   └── app_sidebar.dart            # Sidebar
    └── charts/
        └── chart_widgets.dart          # Widgets de gráficos
```

---

## Componentes Principais

### 1. Modelo de Dados (ItemModel)

O `ItemModel` representa uma entidade de dados na aplicação. Ele implementa:

- **Serialização**: Métodos `toMap()` e `fromMap()` para conversão entre objeto Dart e Map (necessário para IndexedDB)
- **Imutabilidade**: Método `copyWith()` para criar cópias com campos atualizados
- **Geração de ID**: Método estático `generateId()` para criar IDs únicos

**Exemplo de uso:**
```dart
final item = ItemModel(
  id: ItemModel.generateId(),
  name: 'Item 1',
  description: 'Descrição do item',
  category: 'Categoria A',
  value: 100.0,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  status: 'active',
);
```

### 2. IndexedDB Service

O `IndexedDBService` é um singleton que gerencia toda a comunicação com o IndexedDB.

#### Inicialização

O serviço cria um banco de dados chamado `dashboard_db` com uma object store chamada `items`. Durante a inicialização, são criados índices para otimizar buscas:

- `name`: Índice para busca por nome
- `category`: Índice para filtro por categoria
- `status`: Índice para filtro por status
- `createdAt`: Índice para ordenação por data

#### Métodos CRUD

- **createItem()**: Adiciona um novo item ao banco
- **getAllItems()**: Retorna todos os itens
- **getItemById()**: Busca um item específico por ID
- **updateItem()**: Atualiza um item existente
- **deleteItem()**: Remove um item do banco

#### Métodos de Busca e Filtro

- **getItemsByCategory()**: Filtra itens por categoria usando índice
- **getItemsByStatus()**: Filtra itens por status usando índice
- **searchItemsByName()**: Busca parcial por nome ou descrição

**Exemplo de uso:**
```dart
final dbService = IndexedDBService();
await dbService.init();

// Criar item
await dbService.createItem(item);

// Buscar todos
final items = await dbService.getAllItems();

// Filtrar por categoria
final filtered = await dbService.getItemsByCategory('Eletrônicos');
```

### 3. State Management com Cubit

O `ItemCubit` gerencia o estado da aplicação relacionado aos itens.

#### Estados

- **ItemInitial**: Estado inicial
- **ItemLoading**: Carregando dados
- **ItemLoaded**: Dados carregados com sucesso
- **ItemError**: Erro ao carregar dados
- **ItemSuccess**: Operação bem-sucedida (create, update, delete)

#### Métodos do Cubit

- **loadItems()**: Carrega todos os itens do IndexedDB
- **createItem()**: Cria um novo item
- **updateItem()**: Atualiza um item existente
- **deleteItem()**: Deleta um item
- **filterItems()**: Filtra itens por texto
- **filterByCategory()**: Filtra por categoria
- **filterByStatus()**: Filtra por status
- **clearFilters()**: Limpa todos os filtros
- **getStatistics()**: Retorna estatísticas agregadas para gráficos

**Exemplo de uso:**
```dart
// No widget
BlocBuilder<ItemCubit, ItemState>(
  builder: (context, state) {
    if (state is ItemLoaded) {
      return ListView.builder(
        itemCount: state.filteredItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(state.filteredItems[index].name),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)

// Para executar ações
context.read<ItemCubit>().createItem(newItem);
context.read<ItemCubit>().deleteItem(itemId);
```

---

## IndexedDB - Persistência Offline-First

### O que é IndexedDB?

IndexedDB é uma API do navegador que fornece um banco de dados NoSQL no lado do cliente. É ideal para aplicações offline-first porque:

- Armazena grandes quantidades de dados estruturados
- Suporta índices para buscas rápidas
- Funciona de forma assíncrona
- Persiste dados mesmo após fechar o navegador

### Como Funciona no Flutter Web

No Flutter Web, usamos o pacote `idb_shim` que fornece uma interface Dart para o IndexedDB nativo do navegador.

#### Estrutura do Banco

```dart
Database: dashboard_db
  └── ObjectStore: items
       ├── Key: id (String)
       └── Índices:
            ├── name
            ├── category
            ├── status
            └── createdAt
```

#### Transações

Todas as operações no IndexedDB são feitas através de transações:

```dart
final transaction = _database!.transaction([_storeName], idb.TransactionMode.readWrite);
final store = transaction.objectStore(_storeName);
await store.put(item.toMap());
await transaction.completed;
```

#### Migrações

Quando o schema do banco muda, usamos `onUpgradeNeeded` para migrar:

```dart
onUpgradeNeeded: (idb.VersionChangeEvent event) {
  final db = event.database as idb.Database;
  if (!db.objectStoreNames.contains(_storeName)) {
    // Criar object store e índices
  }
}
```

---

## State Management com Cubit

### Por que Cubit?

Cubit é uma versão simplificada do Bloc que não requer eventos explícitos. É ideal para operações CRUD simples onde:

- A lógica de negócio é direta
- Não há necessidade de transformar eventos complexos
- O código fica mais limpo e fácil de entender

### Fluxo de Estado

```
User Action → Cubit Method → IndexedDB → New State → UI Update
```

**Exemplo completo:**

1. Usuário clica em "Salvar" no formulário
2. `ItemDrawer` chama `cubit.createItem(item)`
3. `ItemCubit` emite `ItemLoading`
4. `ItemCubit` chama `_dbService.createItem(item)`
5. IndexedDB persiste o item
6. `ItemCubit` chama `loadItems()` para atualizar a lista
7. `ItemCubit` emite `ItemLoaded` com nova lista
8. UI atualiza automaticamente via `BlocBuilder`

### BlocProvider e BlocBuilder

```dart
// No main.dart - Prover o Cubit para toda a app
BlocProvider(
  create: (context) => ItemCubit(dbService)..loadItems(),
  child: MaterialApp(...),
)

// No widget - Escutar mudanças de estado
BlocBuilder<ItemCubit, ItemState>(
  builder: (context, state) {
    // Renderizar baseado no estado
  },
)

// Para executar ações
context.read<ItemCubit>().createItem(item);
```

---

## Material 3 Components

### Componentes Utilizados

#### 1. AppBar
- Header fixo no topo
- Logo à esquerda
- Avatar com dropdown à direita

#### 2. NavigationDrawer / NavigationRail
- Sidebar colapsável
- Navegação entre páginas
- Adapta-se ao tamanho da tela

#### 3. Card
- Container para métricas e gráficos
- Bordas arredondadas (12px)
- Elevação sutil

#### 4. DataTable
- Tabela de dados com ordenação
- Colunas clicáveis para ordenar
- Ações por linha (Edit, Delete)

#### 5. TextField
- Campos de formulário
- Validação integrada
- Ícones prefixos

#### 6. Drawer (endDrawer)
- Drawer lateral para edição
- Formulário completo
- Validação de campos

#### 7. PopupMenuButton
- Menu dropdown no avatar
- Opções: Perfil, Logout

#### 8. Chip
- Tags para categoria e status
- Cores diferentes por status

### Tema Material 3

O tema é configurado em `app_theme.dart` usando `ColorScheme.fromSeed()`:

```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: primaryColor,
  brightness: Brightness.light,
);
```

Isso gera automaticamente uma paleta de cores harmoniosa baseada na cor primária.

---

## Navegação com GoRouter

### Configuração

GoRouter é configurado no `main.dart` usando `ShellRoute` para ter um layout compartilhado:

```dart
GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/table',
          builder: (context, state) => const TablePage(),
        ),
      ],
    ),
  ],
)
```

### Navegação Programática

```dart
// Navegar para uma rota
context.go('/dashboard');
context.go('/table');

// Obter rota atual
final currentRoute = GoRouterState.of(context).uri.path;
```

### ShellRoute

O `ShellRoute` permite ter um layout compartilhado (Header + Sidebar) que envolve todas as rotas filhas, evitando reconstruir o layout a cada navegação.

---

## Responsividade

A aplicação se adapta a três tamanhos de tela:

### Desktop (>1024px)
- Sidebar expandida (250px)
- Layout horizontal completo
- Gráficos em grid de 3 colunas

### Tablet (768-1024px)
- Sidebar colapsável (72px quando colapsada)
- Layout adaptado
- Gráficos em grid de 2 colunas

### Mobile (<768px)
- Sidebar como drawer (abre/fecha)
- Layout vertical
- Gráficos em grid de 1 coluna

### Implementação

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 768;
final isTablet = screenWidth >= 768 && screenWidth < 1024;

if (isMobile) {
  // Usar Drawer
} else {
  // Usar Sidebar fixa
}
```

---

## Fluxo de Dados

### 1. Inicialização da Aplicação

```
main() → IndexedDB.init() → MyApp → BlocProvider → ItemCubit.loadItems()
```

1. App inicia
2. IndexedDB é inicializado
3. `ItemCubit` é criado e carrega itens automaticamente
4. UI renderiza com dados

### 2. Criar Item

```
User preenche form → ItemDrawer.handleSubmit() → ItemCubit.createItem() 
→ IndexedDB.createItem() → ItemCubit.loadItems() → UI atualiza
```

1. Usuário preenche formulário
2. Validação de campos
3. `ItemCubit.createItem()` é chamado
4. Item é persistido no IndexedDB
5. Lista é recarregada
6. UI atualiza automaticamente

### 3. Filtrar Itens

```
User digita busca → TextField.onChanged → ItemCubit.filterItems() 
→ Estado atualizado → UI mostra resultados filtrados
```

1. Usuário digita no campo de busca
2. `ItemCubit.filterItems()` é chamado
3. Estado é atualizado com lista filtrada
4. UI mostra apenas itens que correspondem ao filtro

### 4. Atualizar Item

```
User clica Edit → ItemDrawer abre com dados → User edita → ItemCubit.updateItem() 
→ IndexedDB.updateItem() → ItemCubit.loadItems() → UI atualiza
```

### 5. Deletar Item

```
User clica Delete → Dialog de confirmação → ItemCubit.deleteItem() 
→ IndexedDB.deleteItem() → ItemCubit.loadItems() → UI atualiza
```

---

## Gráficos com fl_chart

### Tipos de Gráficos

1. **LineChart**: Tendência de valores ao longo do tempo
2. **BarChart**: Comparação entre categorias
3. **PieChart**: Distribuição por status

### Preparação de Dados

Os dados são preparados no `DashboardPage` a partir das estatísticas do Cubit:

```dart
final stats = cubit.getStatistics();
final categoryData = Map<String, double>.from(
  (stats['byCategory'] as Map).map(
    (key, value) => MapEntry(key.toString(), (value as int).toDouble()),
  ),
);
```

### Widgets Reutilizáveis

Cada tipo de gráfico é um widget separado em `chart_widgets.dart`:
- `LineChartWidget`
- `BarChartWidget`
- `PieChartWidget`

---

## Boas Práticas Implementadas

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade clara
2. **Singleton Pattern**: `IndexedDBService` é um singleton para garantir uma única instância
3. **Imutabilidade**: Estados são imutáveis, facilitando debug
4. **Error Handling**: Todos os métodos têm tratamento de erro
5. **Validação**: Formulários têm validação completa
6. **Responsividade**: Layout adapta-se a diferentes tamanhos de tela
7. **Material 3**: Uso consistente dos componentes Material 3
8. **Offline-First**: Dados persistem localmente, funcionando sem internet

---

## Conclusão

Esta aplicação demonstra como construir um dashboard web completo usando Flutter, Material 3, IndexedDB e Cubit. A arquitetura é escalável e fácil de manter, seguindo as melhores práticas do Flutter.

Para expandir a aplicação, você pode:
- Adicionar mais entidades (além de Item)
- Implementar sincronização com backend
- Adicionar autenticação
- Implementar tema escuro
- Adicionar mais tipos de gráficos
- Implementar exportação de dados

