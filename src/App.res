%%raw("import './App.css'")
@module("./logo.svg") external logo: string = "default"

type action = ShowInputs | AddExpense(int, string) | AddIncome(int, string)

type transactionType = Increment | Decrement

type transactions = {
  tType: transactionType,
  amount: int,
  transactionDescription: string,
}

type stateType = {
  showInputs: bool,
  income: int,
  expense: int,
  transactions: array<transactions>,
}

type addExpense = (~amount: int, ~transactionDescription: string) => unit
type addIncome = (~amount: int, ~transactionDescription: string) => unit

let initialState = {
  income: 0,
  expense: 0,
  showInputs: false,
  transactions: [],
}

let reducer = (state, action) => {
  switch action {
  | ShowInputs => {...state, showInputs: !state.showInputs}
  | AddIncome(amount, transactionDescription) => {
      ...state,
      income: state.income + amount,
      transactions: Array.append(
        state.transactions,
        [{tType: Increment, amount: amount, transactionDescription: transactionDescription}],
      ),
    }
  | AddExpense(amount, transactionDescription) => {
      ...state,
      expense: state.expense + amount,
      transactions: Array.append(
        state.transactions,
        [{tType: Decrement, amount: amount, transactionDescription: transactionDescription}],
      ),
    }
  }
}

module InputsContainer = {
  @react.component
  let make = (~addExpense: addExpense, ~addIncome: addIncome) => {
    let handleSubmit = (e: ReactEvent.Form.t) => {
      ReactEvent.Synthetic.preventDefault(e)
      let transactionType = ReactEvent.Synthetic.target(e)["transaction-type"]["value"]
      let amount = ReactEvent.Synthetic.target(e)["amount"]["value"] -> int_of_string
      let transactionDescription = ReactEvent.Synthetic.target(
        e,
      )["transaction-description"]["value"]
      if transactionType == "expense" {
        addExpense(~amount, ~transactionDescription)
      } else {
        addIncome(~amount, ~transactionDescription)
      }
    }

    <form onSubmit={handleSubmit} className="form">
      <input placeholder="Add Amount" type_="text" name="amount" />
      <div className="main">
        <div className="radioContainer">
          <input type_="radio" id="expense" name="transaction-type" value="expense" />
          <label htmlFor="expense"> {"Expense"->React.string} </label>
        </div>
        <div className="radioContainer">
          <input type_="radio" id="income" name="transaction-type" value="income" />
          <label htmlFor="income"> {"Income"->React.string} </label>
        </div>
      </div>
      <label htmlFor="transaction-description"> {"Transaction Description"->React.string} </label>
      <input
        placeholder="transaction description"
        type_="text"
        id="transaction-description"
        name="transaction-description"
      />
      <button type_="submit"> {"Submit"->React.string} </button>
    </form>
  }
}

module Transactions = {
  @react.component
  let make = (~transactionList: array<transactions>) => {
    Belt.Array.mapWithIndex(transactionList, (i, transaction) => {
      <div
        key={Belt.Int.toString(i)}
        className={`transactionComtainer ${transaction.tType == Increment ? "inco" : "expen"}`}>
        <div> {transaction.amount->React.int} </div>
        <div> {transaction.transactionDescription->React.string} </div>
      </div>
    })->React.array
  }
}

let getInitialState = (name: string) => {
  let jsonString = Js.Nullable.toOption(Global.getItem(~key=name))
  if Belt.Option.isSome(jsonString) {
    let jsonData = Json.parseOrRaise(Belt.Option.getUnsafe(jsonString))
    Js.log(jsonData)

    {
      showInputs: Json.Decode.at(list{"showInputs"}, Json.Decode.bool, jsonData),
      income: Json.Decode.at(list{"income"}, Json.Decode.int, jsonData),
      expense: Json.Decode.at(list{"expense"}, Json.Decode.int, jsonData),
      transactions: Json.Decode.at(
        list{"transactions"},
        Json.Decode.array(ele => {
          tType: Json.Decode.at(list{"tType"}, Json.Decode.int, ele) == 0 ? Increment : Decrement,
          amount: Json.Decode.at(list{"amount"}, Json.Decode.int, ele),
          transactionDescription: Json.Decode.at(
            list{"transactionDescription"},
            Json.Decode.string,
            ele,
          ),
        }),
        jsonData,
      ),
    }
  } else {
    initialState
  }
}

@react.component
let make = () => {
  let data = React.useContext(UserContext.context)
  let (state, dispatch) = React.useReducer(reducer, getInitialState(data.user.name))
  Js.log(data)
  React.useEffect1(() => {
    Global.setItem(
      ~key=data.user.name,
      ~value=Json.stringify(
        Json.Encode.object_(list{
          ("showInputs", Json.Encode.bool(state.showInputs)),
          ("income", Json.Encode.int(state.income)),
          ("expense", Json.Encode.int(state.expense)),
          ("transactions", Json.Encode.array(ele => {
              Json.Encode.object_(list{
                ("amount", Json.Encode.int(ele.amount)),
                ("transactionDescription", Json.Encode.string(ele.transactionDescription)),
                ("tType", Json.Encode.int(ele.tType == Increment ? 0 : 1)),
              })
            }, state.transactions)),
        }),
      ),
    )

    None
  }, [state])

  let onAddCtaClick = _ => dispatch(ShowInputs)
  let addExpense = (~amount: int, ~transactionDescription: string) =>
    dispatch(AddExpense(amount, transactionDescription))
  let addIncome = (~amount: int, ~transactionDescription: string) =>
    dispatch(AddIncome(amount, transactionDescription))

  <div className="App">
    <h1> {"Expense tracker"->React.string} </h1>
    <div>
      <div className="balanceComtainer">
        <span> {"Balance - "->React.string} {(state.income - state.expense)->React.int} </span>
        <button onClick={onAddCtaClick} className="addcCta"> {"Add"->React.string} </button>
      </div>
      <div className="tran">
        <div className="m-10">
          <span> {"Income "->React.string} </span>
          <span className="inc"> {state.income->React.int} </span>
        </div>
        <div className="m-10">
          <span> {"Expense "->React.string} </span>
          <span className="exp"> {state.expense->React.int} </span>
        </div>
      </div>
      {state.showInputs
        ? <InputsContainer addExpense={addExpense} addIncome={addIncome} />
        : React.null}
      <Transactions transactionList={state.transactions} />
    </div>
  </div>
}
