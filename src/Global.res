@scope("localStorage") @val external setItem: (~key: string, ~value: string) => unit = "setItem"
@scope("localStorage") @val external getItem: (~key: string) => Js.Nullable.t<'a> = "getItem"
