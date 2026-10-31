import Lake
open Lake DSL

-- Root workspace so editors (VS Code infoview) can resolve `import ContractForge`
-- for generated specs under runs/. The library itself lives in framework/.
package autose

require contractforge from "framework"
