def main(event, context):
    fecha = event.get("fecha")
    vuelos = event.get("vuelos", [])

    lines = [f"Vuelos despegados el {fecha} (UTC):"]
    for vuelo in vuelos:
        line = f"- {vuelo.get('flight_id')} {vuelo.get('ciudad_origen')} → {vuelo.get('ciudad_destino')} {vuelo.get('hora_salida')}"
        lines.append(line)

    reporte_txt = "\n".join(lines)
    # Se pasa al siguiente paso como string
    return {"fecha": fecha, "reporte": reporte_txt}
