%%raw("import './home.css'")

@react.component
let make = () => {
  let (name, setName) = React.useState(() => "")
  let data = React.useContext(UserContext.context)
  let onNameChange = (e: ReactEvent.Form.t) => setName(ReactEvent.Form.currentTarget(e)["value"])
  let onSubmitClick = _ => {
    Global.setItem(~key="name", ~value=name)
    data.setUser(_ => name)
    RescriptReactRouter.push("/dashboard")
  }

  <div className="homeMain">
    <input type_="text" placeholder="Enter Name" value=name onChange=onNameChange />
    <button onClick=onSubmitClick> {"Submit"->React.string} </button>
  </div>
}
