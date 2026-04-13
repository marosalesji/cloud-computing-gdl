# Practica guiada: github actions

Revisa el repositorio https://github.com/marosalesji/mini-notes y responde las
siguientes pregunteas.

## Preguntas

### CI/CD
- ¿Este repositorio cuenta con CI/CD? Continuous Integration, Continuous
  Delivery and Continuous Deployment.
- ¿Qué workflow se ejecuta cuando abres un PR?
- ¿Cómo se hace trigger al pipeline de deploy?
- ¿En cuál ambiente de la nube se hace el deployment de esta aplicación?
- ¿Qué pasa en Docker Hub cuando haces git push origin v0.2.0?
- ¿Cuántos tags se crean en Docker Hub con cada release y por qué?

### The twelve factor app
- ¿Cuáles de los 12 factores utiliza este proyecto? ¿Cuáles no utiliza?
- Elige 1 de los 12 factores que no está en esta aplicación, ¿cómo lo
  implementarías?
- ¿Qué pasa con las notas si el contenedor se reinicia? ¿Cumple el factor VI?
  ¿Cómo lo resolverías sin cambiar el código de la app? [Factor VI Processes]
- `requirements.txt` tiene versiones fijas (`fastapi==0.135.3`). ¿Por qué es
  importante fijarlas? ¿Qué pasaría si no lo hicieras en el contexto del CI?
  [Factor II Dependencies]
- Identifica en qué workflow ocurre el *build*, en cuál el *release* y en cuál
  el *run*. ¿Puedes hacer un *run* sin haber pasado por *build*? [Factor V
  Build/Release/Run]
- La app no tiene logs. Si el contenedor falla en EC2, ¿cómo debuggeas?
  ¿Cómo lo implementarías? [Factor XI Logs]
