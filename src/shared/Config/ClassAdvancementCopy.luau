--!strict
-- Scoped localized copy uses the same required level as server readiness.
-- Do not embed dynamic class levels in images or legacy translated constants.
local M={}
local headers:{[string]:string}={
 en="Class 2: Lv%d + Quarry Patrol. Class 3: Lv70 + Tower floor 5. Choices are permanent.",
 th="ขั้น 2: เลเวล %d และจบลาดตระเวนเหมือง ขั้น 3: เลเวล 70 และผ่านหอคอยชั้น 5 เลือกสายแล้วเปลี่ยนไม่ได้",
}
function M.header(language:string,classTwoLevel:number):string
 return string.format(headers[language] or headers.en,classTwoLevel)
end
return M
