from __future__ import annotations
from pydantic import BaseModel
from typing import Dict, Tuple
from datetime import datetime


class Lizenzen(BaseModel):
    """
    Tabelle zur Verwaltung der Lizenzen, unter denen die statistischen Daten veröffentlicht werden.
    """
    name: str  # Name der Lizenz (z.B. CC BY 4.0).
    url: str  # URL zur vollständigen Lizenzbeschreibung.
    extra_bedingungen: bool  # Gibt an, ob zusätzliche Bedingungen für die Nutzung der Daten bestehen.


class Daten(BaseModel):
    """
    Tabelle für die Speicherung von statistischen Einzelwerten (Zeitreihen) zu Ländern und Indikatoren.
    """
    datum: datetime  # Datum, an dem der Wert erhoben oder veröffentlicht wurde.
    wert: float  # Erfasster numerischer Wert für das jeweilige Land und den Indikator am angegebenen Datum.
    berechnet: bool  # Gibt an, ob der Wert berechnet wurde.
    laender: Laender  # Verweis auf das Land, für das der Wert gilt.
    indikatoren: Indikatoren  # Verweis auf den Indikator, zu dem der Wert gehört.
    lizenzen: Lizenzen  # Verweis auf die Lizenz, unter welcher der Wert steht.
    quellen: Quellen  # Verweis auf die Quelle, aus welcher der Wert stammt.


class Metadaten_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Metadaten zu.
    """
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    metadaten: Metadaten  # Verweis auf das zugeordnete Metadatum.


class Ugl_werte(BaseModel):
    """
    Tabelle zur Verwaltung der Werte der Untergliederungen von Indikatoren.
    """
    name: str  # Name des Untergliederungwertes.
    untergliederungen: Ugl  # Optionalee Referenz auf die Untergliederung.
    laender: Laender  # Referenz auf ein Land.


class Laendergruppen(BaseModel):
    """
    Tabelle zur Verwaltung von Ländergruppen (z.B. EU, OECD, G7).
    """
    name_de: str  # Name der Ländergruppe auf Deutsch.
    name_en: str  # Name der Ländergruppe auf Englisch.


class Downloadquellen_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Download-Quellen zu.
    """
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    quellen: Quellen  # Verweis auf die zugeordnete Download-Quelle.


class Ugl_zo(BaseModel):
    """
    Diese Tabelle ordnet Daten ihre Untergliederungswerte zu.
    """
    untergliederungswerte: Ugl_werte  # Verweis auf den zugeordneten Untergliederungswert.
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.


class Metadaten(BaseModel):
    """
    Tabelle zur Verwaltung von Metadaten, die Datenpunkten zugeordnet werden können (z.B. methodische Hinweise, Fußnoten).
    """
    kuerzel: str  # Kürzel für das Metadatum.
    bezeichnung: str  # Ausführliche Bezeichnung des Metadatums.


class Ugl(BaseModel):
    """
    Tabelle zur Verwaltung der möglichen Untergliederungen eines Indikators.
    """
    name: str  # Name der Untergliederung.


class Nutzer(BaseModel):
    """
    Diese Tabelle speichert alle Nutzer.
    """
    name: str  # Name des Nutzers.


class Laendergruppen_zo(BaseModel):
    """
    Tabelle zur Zuordnung von Ländern zu Ländergruppen (z.B. Mitgliedschaft eines Landes in einer Gruppe).
    """
    laender: Laender  # Verweis auf das zugeordnete Land.
    laendergruppen: Laendergruppen  # Verweis auf die zugeordnete Ländergruppe.


class Quellen(BaseModel):
    """
    Tabelle zur Verwaltung von Datenquellen.
    """
    name_de: str  # Vollständiger Name der Quelle auf Deutsch.
    name_en: str  # Vollständiger Name der Quelle auf Englisch.
    name_kurz_de: str  # Kurzer Name der Quelle auf Deutsch.
    name_kurz_en: str  # Kurzer Name der Quelle auf Englisch.
    url: str  # Link zu der Quelle.


class Indikatoren(BaseModel):
    """
    Tabelle zur Verwaltung der statistischen Indikatoren.
    """
    faktor: float  # Faktor zur Multiplikation mit dem Indikatorwerts, um den korrekten Wert zu erhalten.
    dezimalstellen: int  # Anzahl der Dezimalstellen, mit denen der Wert angezeigt wird.
    name_de: str  # Name des Indikators auf Deutsch.
    name_en: str  # Name des Indikators auf Englisch.
    beschreibung_de: str  # Ausführliche Beschreibung des Indikators auf Deutsch.
    beschreibung_en: str  # Ausführliche Beschreibung des Indikators auf Englisch.
    quellen_indikatoren_id: str  # ID des Indikators bei der jeweiligen Quelle (optional).
    themen: Themen  # Verweis auf das Thema, dem der Indikator zugeordnet ist.
    einheiten: Einheiten  # Verweis auf die Einheit, in der der Indikator gemessen wird.


class Themen(BaseModel):
    """
    Tabelle welche Themen verwaltet, denen Indikatoren zugeordnet sind.
    """
    name_de: str  # Name des Themas auf Deutsch.
    name_en: str  # Name des Themas auf Englisch.
    farbe: Tuple[int, int, int]


class Laender(BaseModel):
    """
    Tabelle zur Verwaltung der Länder mit ISO-Codes und Namensreferenzen.
    """
    iso2: str  # ISO-2-Ländercode gemäß internationalem Standard (z.B. 'DE' für Deutschland).
    iso3: str  # ISO-3-Ländercode gemäß internationalem Standard (z.B. 'DEU' für Deutschland).
    kontinente: Kontinente  # Verweis auf den Kontinent, dem das Land zugeordnet ist.
    laendernamen_de: Laendernamen  # Verweis auf den deutschen Namen des Landes.
    laendernamen_en: Laendernamen  # Verweis auf den englischen Namen des Landes.


class Einheiten(BaseModel):
    """
    Tabelle zur Verwaltung der Einheiten, in denen statistische Werte angegeben werden.
    """
    faktor: float  # Faktor zur Umrechnung in die Basiseinheit.
    symbol_de: str  # Symbol der Einheit auf Deutsch.
    symbol_en: str  # Symbol der Einheit auf Englisch.
    basis_einheiten: Einheiten  # Optionale Referenz auf eine Basiseinheit, falls die Einheit abgeleitet ist.


class Laendernamen(BaseModel):
    """
    Tabelle zuer Verwaltung von Ländernamen. Ein Land kann mehrere Ländernamen haben. Jedes Land hat einen deutschen und einen englischen Namen.
    """
    name: str  # Name eines Landes.
    laender: Laender  # Verweis auf das Land, dem der Name zugeordnet ist. (optional)


class Kontinente(BaseModel):
    """
    Tabelle zur Verwaltung der Kontinente, denen Länder zugeordnet werden können.
    """
    name_de: str  # Name des Kontinents auf Deutsch.
    name_en: str  # Name des Kontinents auf Englisch.


class Quellen_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Quellen zu.
    """
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    quellen: Quellen  # Verweis auf die zugeordnete Quelle.


MODELS: Dict[str, BaseModel] = {  # type: ignore
    "lizenzen": Lizenzen,
    "daten": Daten,
    "metadaten_zo": Metadaten_zo,
    "ugl_werte": Ugl_werte,
    "laendergruppen": Laendergruppen,
    "downloadquellen_zo": Downloadquellen_zo,
    "ugl_zo": Ugl_zo,
    "metadaten": Metadaten,
    "ugl": Ugl,
    "nutzer": Nutzer,
    "laendergruppen_zo": Laendergruppen_zo,
    "quellen": Quellen,
    "indikatoren": Indikatoren,
    "themen": Themen,
    "laender": Laender,
    "einheiten": Einheiten,
    "laendernamen": Laendernamen,
    "kontinente": Kontinente,
    "quellen_zo": Quellen_zo,
}