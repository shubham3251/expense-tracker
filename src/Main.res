open UserContext

@react.component
let make = () => {
  let (route, setRoute) = React.useState(() => "/")
  let (user, setUser) = React.useState(() => "")

  React.useEffect0(() => {
    let id = RescriptReactRouter.watchUrl(route => {
      setRoute(_ => List.fold_left((acc, ele) => {
          acc ++ "/" ++ ele
        }, "", route.path))
    })

    Some(() => RescriptReactRouter.unwatchUrl(id))
  })

  <UserContext.Provider value={user: {name: user}, setUser: setUser}>
    {switch route {
    | "/" => <Home />
    | "/dashboard" => <App />
    | _ => <NotFound />
    }}
  </UserContext.Provider>
}
