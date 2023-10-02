let rootQuery = ReactDOM.querySelector("#root")

switch rootQuery {
| None => ()
| Some(root) => ReactDOM.render(<Main />, root)
}