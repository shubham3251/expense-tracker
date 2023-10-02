type user = {name: string}
type contextValue = {
  user: user,
  setUser: (string => string) => unit,
}

let context = React.createContext({user: {name: ""}, setUser: _ => ()})
module Provider = {
  let provider = React.Context.provider(context)
  @react.component
  let make = (~value, ~children) =>
    React.createElement(provider, {"value": value, "children": children})
}
