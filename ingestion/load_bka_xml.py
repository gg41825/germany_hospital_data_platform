from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import xml.etree.ElementTree as ET

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Load Bundes-Klinik-Atlas XML data into PostgreSQL raw tables."
    )
    parser.add_argument("xml_path", type=Path, help="Path to the BKA XML export.")
    parser.add_argument(
        "--raw-schema",
        default=os.getenv("RAW_SCHEMA", "raw_bka"),
        help="PostgreSQL schema for raw source tables.",
    )
    return parser.parse_args()


def extract_standort_kontakt(xml_path: Path) -> pd.DataFrame:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    rows: list[dict[str, str | None]] = []
    for standort in root.findall("Standort"):
        kontakt = standort.find("StandortKontaktDaten")
        if kontakt is None:
            continue

        rows.append(
            {
                "stoid": kontakt.attrib.get("STOID"),
                "land": kontakt.attrib.get("Land"),
                "name": kontakt.attrib.get("Name"),
                "strasse": kontakt.attrib.get("Strasse"),
                "plz": kontakt.attrib.get("PLZ"),
                "ort": kontakt.attrib.get("Ort"),
                "url": kontakt.attrib.get("URL"),
                "telefon": kontakt.attrib.get("Telefon"),
                "email": kontakt.attrib.get("EMail"),
                "traegerart": kontakt.attrib.get("TraegerArt"),
                "kinderklinik": kontakt.attrib.get("Kinderklinik"),
                "sicherstellungsauftrag": kontakt.attrib.get("Sicherstellungsauftrag"),
                "georeferenzzone": kontakt.attrib.get("GeoreferenzZone"),
                "georeferenzost": kontakt.attrib.get("GeoreferenzOst"),
                "georeferenznord": kontakt.attrib.get("GeoreferenzNord"),
                "laengengrad": kontakt.attrib.get("Laengengrad"),
                "breitengrad": kontakt.attrib.get("Breitengrad"),
            }
        )

    return pd.DataFrame(rows)


def extract_standort_struktur(xml_path: Path) -> pd.DataFrame:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    rows: list[dict[str, str | None]] = []
    for standort in root.findall("Standort"):
        kontakt = standort.find("StandortKontaktDaten")
        struktur = standort.find("StandortStrukturDaten")
        if kontakt is None or struktur is None:
            continue

        rows.append(
            {
                "stoid": kontakt.attrib.get("STOID"),
                "anzahlfab": struktur.attrib.get("AnzahlFAB"),
                "anzahlbetten": struktur.attrib.get("AnzahlBetten"),
                "anzahlteilstationaerbehandlungsplaetze": struktur.attrib.get(
                    "AnzahlTeilstationaerBehandlungsplaetze"
                ),
                "anzahlfaelle": struktur.attrib.get("AnzahlFaelle"),
                "anzahlpfleger": struktur.attrib.get("AnzahlPfleger"),
                "pflegepersonalquotient": struktur.attrib.get("PflegePersonalQuotient"),
            }
        )

    return pd.DataFrame(rows)


def extract_standort_notfallversorgung(xml_path: Path) -> pd.DataFrame:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    rows: list[dict[str, str | None]] = []
    for standort in root.findall("Standort"):
        kontakt = standort.find("StandortKontaktDaten")
        notfallversorgung = standort.find("StandortNotfallversorgung")
        if kontakt is None or notfallversorgung is None:
            continue

        rows.append(
            {
                "stoid": kontakt.attrib.get("STOID"),
                "stufe": notfallversorgung.attrib.get("Stufe"),
                "schwerverletztenversorgung": notfallversorgung.attrib.get(
                    "Schwerverletztenversorgung"
                ),
                "kinder": notfallversorgung.attrib.get("Kinder"),
                "spezialversorgung": notfallversorgung.attrib.get("Spezialversorgung"),
                "strokeunit": notfallversorgung.attrib.get("StrokeUnit"),
                "chestpainunit": notfallversorgung.attrib.get("ChestPainUnit"),
                "stufenichtvereinbart": notfallversorgung.attrib.get(
                    "StufeNichtVereinbart"
                ),
            }
        )

    return pd.DataFrame(rows)


def extract_erkrankungen(xml_path: Path) -> pd.DataFrame:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    rows: list[dict[str, str | None]] = []
    for standort in root.findall("Standort"):
        kontakt = standort.find("StandortKontaktDaten")
        erkrankungen = standort.find("Erkrankungen")
        if kontakt is None or erkrankungen is None:
            continue

        stoid = kontakt.attrib.get("STOID")
        for erkrankung in erkrankungen.findall("Erkrankung"):
            rows.append(
                {
                    "stoid": stoid,
                    "name": erkrankung.attrib.get("Name"),
                    "gruppe": erkrankung.attrib.get("Gruppe"),
                    "anzahl": erkrankung.attrib.get("Anzahl"),
                }
            )

    return pd.DataFrame(rows)


def extract_fachabteilungen(xml_path: Path) -> pd.DataFrame:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    rows: list[dict[str, str | None]] = []
    for standort in root.findall("Standort"):
        kontakt = standort.find("StandortKontaktDaten")
        fachabteilungen = standort.find("Fachabteilungen")
        if kontakt is None or fachabteilungen is None:
            continue

        stoid = kontakt.attrib.get("STOID")
        for fachabteilung in fachabteilungen.findall("Fachabteilung"):
            rows.append(
                {
                    "stoid": stoid,
                    "fabid": fachabteilung.attrib.get("FABID"),
                    "bezeichnung": fachabteilung.attrib.get("Bezeichnung"),
                    "anzahlfaelle": fachabteilung.attrib.get("AnzahlFaelle"),
                }
            )

    return pd.DataFrame(rows)


def load_raw_tables(
    standort_kontakt_df: pd.DataFrame,
    standort_struktur_df: pd.DataFrame,
    standort_notfallversorgung_df: pd.DataFrame,
    erkrankungen_df: pd.DataFrame,
    fachabteilungen_df: pd.DataFrame,
    raw_schema: str,
) -> None:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", raw_schema):
        raise ValueError(
            "RAW_SCHEMA must be a valid PostgreSQL identifier "
            f"(received {raw_schema!r})."
        )

    database_url = build_postgres_url()
    engine = create_engine(database_url)

    with engine.begin() as conn:
        conn.execute(text(f'create schema if not exists "{raw_schema}"'))

    write_dataframe(standort_kontakt_df, "standort_kontakt", raw_schema, engine)
    write_dataframe(standort_struktur_df, "standort_struktur", raw_schema, engine)
    write_dataframe(
        standort_notfallversorgung_df,
        "standort_notfallversorgung",
        raw_schema,
        engine,
    )
    write_dataframe(erkrankungen_df, "erkrankungen", raw_schema, engine)
    write_dataframe(fachabteilungen_df, "fachabteilungen", raw_schema, engine)
    engine.dispose()


def build_postgres_url() -> URL:
    env = {
        "PGHOST": os.getenv("PGHOST", "localhost"),
        "PGPORT": os.getenv("PGPORT", "5432"),
        "PGUSER": os.getenv("PGUSER"),
        "PGPASSWORD": os.getenv("PGPASSWORD"),
        "PGDATABASE": os.getenv("PGDATABASE"),
    }
    missing = [key for key, value in env.items() if not value]
    if missing:
        raise ValueError(
            "Missing PostgreSQL environment variables: " + ", ".join(sorted(missing))
        )

    return URL.create(
        "postgresql+psycopg",
        username=env["PGUSER"],
        password=env["PGPASSWORD"],
        host=env["PGHOST"],
        port=int(env["PGPORT"]),
        database=env["PGDATABASE"],
        query={"sslmode": os.getenv("PGSSLMODE", "prefer")},
    )


def write_dataframe(
    dataframe: pd.DataFrame,
    table_name: str,
    raw_schema: str,
    engine,
) -> None:
    dataframe.to_sql(
        name=table_name,
        con=engine,
        schema=raw_schema,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=1000,
    )


def main() -> None:
    args = parse_args()
    xml_path = args.xml_path
    if not xml_path.is_file():
        raise FileNotFoundError(f"XML file not found at path: {xml_path}")
    raw_schema = args.raw_schema
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", raw_schema):
        raise ValueError(
            "RAW_SCHEMA must be a valid PostgreSQL identifier "
            f"(received {raw_schema!r})."
        )
    standort_kontakt_df = extract_standort_kontakt(xml_path)
    standort_struktur_df = extract_standort_struktur(xml_path)
    standort_notfallversorgung_df = extract_standort_notfallversorgung(xml_path)
    erkrankungen_df = extract_erkrankungen(xml_path)
    fachabteilungen_df = extract_fachabteilungen(xml_path)
    load_raw_tables(
        standort_kontakt_df,
        standort_struktur_df,
        standort_notfallversorgung_df,
        erkrankungen_df,
        fachabteilungen_df,
        raw_schema,
    )
    print(
        f"Loaded {len(standort_kontakt_df)} rows into {raw_schema}.standort_kontakt "
        f"and {len(standort_struktur_df)} rows into {raw_schema}.standort_struktur "
        f"and {len(standort_notfallversorgung_df)} rows into "
        f"{raw_schema}.standort_notfallversorgung "
        f"and {len(erkrankungen_df)} rows into {raw_schema}.erkrankungen "
        f"and {len(fachabteilungen_df)} rows into {raw_schema}.fachabteilungen "
        f"in schema {raw_schema} on PostgreSQL database {os.getenv('PGDATABASE')}"
    )


if __name__ == "__main__":
    main()
